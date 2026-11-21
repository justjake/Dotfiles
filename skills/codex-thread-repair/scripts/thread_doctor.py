#!/usr/bin/env python3
"""Audit and narrowly repair Codex paginated-thread projection checkpoints."""

from __future__ import annotations

import argparse
import fcntl
import json
import os
import sqlite3
from collections.abc import Iterable, Iterator
from contextlib import ExitStack, closing, contextmanager, suppress
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path
from uuid import UUID


@dataclass(frozen=True)
class Thread:
    thread_id: str
    name: str
    rollout_path: Path


@dataclass(frozen=True)
class Finding:
    thread: Thread
    old_offset: int
    expected_ordinal: int
    rollout_size: int
    expected_positions: tuple[int, ...]
    malformed_lines: int
    loaded: bool
    queued_items: int
    in_progress_turns: tuple[str, ...]
    highest_ordinal: int | None
    rollout_id: str | None
    earlier_unprojected: bool
    complete_final_line: bool
    stable_scan: bool
    file_signature: tuple[int, int, int, int]

    @property
    def checkpoint_consistent(self) -> bool:
        return (
            self.stable_scan
            and self.old_offset == self.rollout_size
            and self.complete_final_line
            and self.highest_ordinal is not None
            and self.expected_ordinal == self.highest_ordinal + 1
        )

    @property
    def can_realign(self) -> bool:
        return (
            self.stable_scan
            and self.malformed_lines == 0
            and self.complete_final_line
            and not self.earlier_unprojected
            and self.rollout_id == self.thread.thread_id
            and len(self.expected_positions) == 1
            and self.expected_positions[0] != self.old_offset
        )

    @property
    def status(self) -> str:
        if self.checkpoint_consistent:
            return "caught-up-with-anomalies" if self.malformed_lines else "healthy"
        if (
            self.stable_scan
            and not self.malformed_lines
            and self.complete_final_line
            and self.expected_positions == (self.old_offset,)
            and not self.earlier_unprojected
        ):
            return "awaiting-projection"
        if self.loaded:
            return "loaded"
        if not self.stable_scan or self.malformed_lines or not self.complete_final_line:
            return "unsafe"
        if self.can_realign:
            return "realignable"
        return "unsafe"

    @property
    def new_offset(self) -> int | None:
        if not self.can_realign:
            return None
        return self.expected_positions[0]


def current_versioned(codex_home: Path, stem: str, open_targets: set[str]) -> Path:
    paths = list(codex_home.glob(f"{stem}_*.sqlite"))
    if not paths:
        raise SystemExit(f"no {stem}_*.sqlite found under {codex_home}")
    open_paths = [path for path in paths if str(path) in open_targets]
    if len(open_paths) == 1:
        return open_paths[0]
    if len(open_paths) > 1:
        names = ", ".join(str(path) for path in open_paths)
        raise SystemExit(f"multiple open {stem} databases found: {names}")
    return max(paths, key=lambda path: path.stat().st_mtime_ns)


def readonly(path: Path) -> sqlite3.Connection:
    connection = sqlite3.connect(f"{path.resolve().as_uri()}?mode=ro", uri=True)
    connection.row_factory = sqlite3.Row
    return connection


def open_file_targets() -> set[str]:
    targets: set[str] = set()
    for process in Path("/proc").iterdir():
        if not process.name.isdigit():
            continue
        try:
            descriptors = (process / "fd").iterdir()
            for descriptor in descriptors:
                with suppress(OSError):
                    targets.add(os.readlink(descriptor))
        except (FileNotFoundError, PermissionError):
            pass
    return targets


def matching_threads(
    state: sqlite3.Connection, terms: tuple[str, ...], include_all: bool
) -> list[Thread]:
    rows = state.execute(
        """
        SELECT id, coalesce(nullif(name, ''), title) AS display_name, rollout_path
        FROM threads
        WHERE history_mode = 'paginated'
        ORDER BY updated_at DESC
        """
    )
    matches: list[Thread] = []
    lowered = tuple(term.casefold() for term in terms)
    for row in rows:
        haystack = f"{row['display_name']} {row['id']}".casefold()
        if include_all or all(term in haystack for term in lowered):
            matches.append(
                Thread(row["id"], row["display_name"], Path(row["rollout_path"]))
            )
    return matches


def file_signature(path: Path) -> tuple[int, int, int, int]:
    stat = path.stat()
    return (stat.st_dev, stat.st_ino, stat.st_size, stat.st_mtime_ns)


@dataclass(frozen=True)
class RolloutScan:
    positions: tuple[int, ...]
    malformed: int
    highest_ordinal: int | None
    rollout_id: str | None
    earlier_unprojected: bool
    complete: bool
    stable: bool
    signature: tuple[int, int, int, int]


def parse_record(line: bytes) -> dict | None:
    if not line.endswith(b"\n"):
        return None
    try:
        value = json.loads(line)
    except (ValueError, RecursionError):
        return None
    return value if isinstance(value, dict) else None


def record_ordinal(value: dict) -> int | None:
    ordinal = value.get("ordinal")
    return ordinal if type(ordinal) is int and 0 <= ordinal < (1 << 63) - 1 else None


def scan_rollout(path: Path, expected: int) -> RolloutScan:
    before = file_signature(path)
    positions: list[int] = []
    malformed = 0
    highest_ordinal = None
    rollout_id = None
    earlier_unprojected = False
    final_line = b""
    with path.open("rb") as rollout:
        while line := rollout.readline():
            final_line = line
            position = rollout.tell() - len(line)
            if not line.strip() and line.endswith(b"\n"):
                continue
            value = parse_record(line)
            if value is None:
                malformed += 1
                continue
            if position == 0 and value.get("type") == "session_meta":
                payload = value.get("payload")
                if isinstance(payload, dict) and isinstance(payload.get("id"), str):
                    rollout_id = payload["id"]
            ordinal = record_ordinal(value)
            if ordinal is None:
                malformed += 1
                continue
            if ordinal == expected:
                positions.append(position)
            elif ordinal > expected and not positions:
                earlier_unprojected = True
            if highest_ordinal is None or ordinal > highest_ordinal:
                highest_ordinal = ordinal
    after = file_signature(path)
    return RolloutScan(
        tuple(positions),
        malformed,
        highest_ordinal,
        rollout_id,
        earlier_unprojected,
        final_line.endswith(b"\n"),
        before == after,
        after,
    )


def count_queued(queue: sqlite3.Connection | None, thread_id: str) -> int:
    if queue is None:
        return 0
    row = queue.execute(
        "SELECT count(*) FROM queued_items WHERE thread_id = ?", (thread_id,)
    ).fetchone()
    return int(row[0])


def audit(
    threads: Iterable[Thread],
    history: sqlite3.Connection,
    queue: sqlite3.Connection | None,
    open_targets: set[str],
) -> list[Finding]:
    findings: list[Finding] = []
    for thread in threads:
        if not thread.rollout_path.exists():
            print(f"unsafe  {thread.thread_id}  rollout missing: {thread.rollout_path}")
            continue
        state = history.execute(
            """
            SELECT next_rollout_byte_offset, next_rollout_ordinal
            FROM thread_history_projection_state WHERE thread_id = ?
            """,
            (thread.thread_id,),
        ).fetchone()
        if state is None:
            print(f"unsafe  {thread.thread_id}  projection state missing")
            continue
        old_offset = int(state["next_rollout_byte_offset"])
        expected = int(state["next_rollout_ordinal"])
        try:
            scan = scan_rollout(thread.rollout_path, expected)
        except OSError as error:
            print(f"unsafe  {thread.thread_id}  rollout unreadable: {error}")
            continue
        in_progress = tuple(
            row[0]
            for row in history.execute(
                """
                SELECT turn_id FROM thread_turns
                WHERE thread_id = ? AND status = 'inProgress'
                ORDER BY rollout_ordinal
                """,
                (thread.thread_id,),
            )
        )
        findings.append(
            Finding(
                thread=thread,
                old_offset=old_offset,
                expected_ordinal=expected,
                rollout_size=scan.signature[2],
                expected_positions=scan.positions,
                malformed_lines=scan.malformed,
                loaded=str(thread.rollout_path) in open_targets,
                queued_items=count_queued(queue, thread.thread_id),
                in_progress_turns=in_progress,
                highest_ordinal=scan.highest_ordinal,
                rollout_id=scan.rollout_id,
                earlier_unprojected=scan.earlier_unprojected,
                complete_final_line=scan.complete,
                stable_scan=scan.stable,
                file_signature=scan.signature,
            )
        )
    return findings


def print_finding(finding: Finding) -> None:
    details = [
        f"ordinal={finding.expected_ordinal}",
        f"offset={finding.old_offset}",
        f"size={finding.rollout_size}",
    ]
    if finding.new_offset is not None:
        details.append(f"new_offset={finding.new_offset}")
    if finding.malformed_lines:
        details.append(f"malformed={finding.malformed_lines}")
    if finding.loaded:
        details.append("loaded=true")
    if not finding.stable_scan:
        details.append("raw_changed_during_scan=true")
    if finding.queued_items:
        details.append(f"queued={finding.queued_items}")
    if finding.in_progress_turns:
        details.append(f"inProgress={','.join(finding.in_progress_turns)}")
    print(
        f"{finding.status:11} {finding.thread.thread_id}  "
        f"{finding.thread.name!r}  {' '.join(details)}"
    )


def backup_database(history_path: Path, codex_home: Path, label: str) -> Path:
    directory = codex_home / "thread-repair-backups"
    directory.mkdir(mode=0o700, exist_ok=True)
    stamp = datetime.now(UTC).strftime("%Y%m%dT%H%M%S%fZ")
    destination = directory / f"{history_path.stem}-before-{label}-{stamp}.sqlite"
    source = sqlite3.connect(history_path)
    backup = sqlite3.connect(destination)
    try:
        source.backup(backup)
    finally:
        backup.close()
        source.close()
    return destination


@contextmanager
def writer_locks(codex_home: Path, thread_ids: Iterable[str]) -> Iterator[None]:
    directory = codex_home / "thread-writer-locks"
    # Require an initialized namespace. Hold shared coordination while opening
    # each lock so Codex cannot unlink and replace the inode during acquisition.
    with ExitStack() as locks:
        with (directory / ".coordination.lock").open("r+b") as coordination:
            fcntl.flock(coordination, fcntl.LOCK_SH | fcntl.LOCK_NB)
            for thread_id in sorted(set(thread_ids)):
                if str(UUID(thread_id)) != thread_id:
                    raise ValueError(f"invalid writer lock ID: {thread_id}")
                lock = locks.enter_context(
                    (directory / f"{thread_id}.lock").open("a+b")
                )
                try:
                    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
                except BlockingIOError:
                    raise SystemExit(
                        f"active Codex writer for {thread_id}; repair refused"
                    )
        yield


def recheck(
    finding: Finding, open_targets: set[str], *, allow_loaded: bool = False
) -> None:
    path = finding.thread.rollout_path
    if (str(path) in open_targets and not allow_loaded) or file_signature(
        path
    ) != finding.file_signature:
        raise RuntimeError(f"rollout loaded or changed for {finding.thread.thread_id}")


def checkpoint_matches(connection: sqlite3.Connection, finding: Finding) -> bool:
    row = connection.execute(
        """
        SELECT next_rollout_byte_offset, next_rollout_ordinal
        FROM thread_history_projection_state WHERE thread_id = ?
        """,
        (finding.thread.thread_id,),
    ).fetchone()
    return row == (finding.old_offset, finding.expected_ordinal)


@contextmanager
def publication_lock(path: Path) -> Iterator[None]:
    # Codex takes exclusive coordination before publishing a replacement rollout.
    # An existing recorder can append, so the repair also checks file signatures.
    with path.open("r+b") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        yield


def repair(
    history_path: Path,
    codex_home: Path,
    findings: Iterable[Finding],
    allow_loaded: bool = False,
) -> tuple[Path | None, int]:
    selected = [
        finding
        for finding in findings
        if finding.can_realign
        and (
            not finding.loaded
            or (allow_loaded and finding.old_offset > finding.rollout_size)
        )
    ]
    if not selected:
        return None, 0
    backup = backup_database(history_path, codex_home, "checkpoint-repair")
    if allow_loaded and selected[0].loaded:
        coordination = codex_home / "thread-writer-locks" / ".coordination.lock"
        lock = publication_lock(coordination)
    else:
        lock = writer_locks(codex_home, (item.thread.thread_id for item in selected))
    with lock:
        with (
            closing(sqlite3.connect(history_path, timeout=5.0)) as connection,
            connection,
        ):
            connection.execute("BEGIN IMMEDIATE")
            targets = open_file_targets()
            for finding in selected:
                recheck(finding, targets, allow_loaded=allow_loaded and finding.loaded)
                cursor = connection.execute(
                    """
                    UPDATE thread_history_projection_state
                    SET next_rollout_byte_offset = ?
                    WHERE thread_id = ?
                      AND next_rollout_byte_offset = ?
                      AND next_rollout_ordinal = ?
                    """,
                    (
                        finding.new_offset,
                        finding.thread.thread_id,
                        finding.old_offset,
                        finding.expected_ordinal,
                    ),
                )
                if cursor.rowcount != 1:
                    raise RuntimeError(
                        f"projection changed for {finding.thread.thread_id}"
                    )
            targets = open_file_targets()
            for finding in selected:
                recheck(finding, targets, allow_loaded=allow_loaded and finding.loaded)
        return backup, len(selected)


@dataclass(frozen=True)
class Abort:
    ordinal: int
    end_offset: int
    root_turn_id: str | None
    started_at: int | None
    completed_at: int | None
    duration_ms: int | None


def abort_records(finding: Finding) -> dict[str, Abort]:
    # Only restore a terminal boundary directly backed by a unique, ordered
    # durable event. Competing terminal events or ordinal regressions are ambiguous.
    records: dict[str, Abort] = {}
    seen: set[str] = set()
    previous = -1
    with finding.thread.rollout_path.open("rb") as rollout:
        while line := rollout.readline():
            if not line.strip():
                continue
            value = parse_record(line)
            ordinal = record_ordinal(value) if value is not None else None
            if ordinal is None or ordinal <= previous:
                return {}
            previous = ordinal
            payload = value.get("payload")
            if value.get("type") != "event_msg" or not isinstance(payload, dict):
                continue
            turn_id = payload.get("turn_id")
            if not isinstance(turn_id, str) or turn_id not in finding.in_progress_turns:
                continue
            kind = payload.get("type")
            if kind not in ("turn_aborted", "task_complete", "turn_complete"):
                continue
            abort = parse_abort(payload, ordinal, rollout.tell())
            if turn_id in seen:
                records.pop(turn_id, None)
            elif abort is not None:
                records[turn_id] = abort
            seen.add(turn_id)
    return records


def parse_abort(payload: dict, ordinal: int, end_offset: int) -> Abort | None:
    if (
        payload.get("type") != "turn_aborted"
        or payload.get("reason")
        not in ("interrupted", "replaced", "review_ended", "budget_limited")
        or payload.get("error") is not None
    ):
        return None
    root = payload.get("root_turn_id")
    if root is not None and not isinstance(root, str):
        return None
    times = (
        payload.get("started_at"),
        payload.get("completed_at"),
        payload.get("duration_ms"),
    )
    if any(
        value is not None
        and (type(value) is not int or not -(1 << 63) <= value < 1 << 63)
        for value in times
    ):
        return None
    return Abort(ordinal, end_offset, root, *times)


def repair_orphans(
    history_path: Path,
    codex_home: Path,
    findings: Iterable[Finding],
) -> tuple[Path | None, int]:
    candidates = [
        (finding, records)
        for finding in findings
        if finding.status == "healthy"
        and not finding.loaded
        and finding.rollout_id == finding.thread.thread_id
        and finding.in_progress_turns
        if (records := abort_records(finding))
    ]
    if not candidates:
        return None, 0
    with writer_locks(codex_home, (item.thread.thread_id for item, _ in candidates)):
        backup = backup_database(history_path, codex_home, "orphan-repair")
        count = 0
        with (
            closing(sqlite3.connect(history_path, timeout=5.0)) as connection,
            connection,
        ):
            connection.execute("BEGIN IMMEDIATE")
            targets = open_file_targets()
            for finding, records in candidates:
                recheck(finding, targets)
                if not checkpoint_matches(connection, finding):
                    raise RuntimeError(
                        f"projection changed for {finding.thread.thread_id}"
                    )
                for turn_id, abort in records.items():
                    cursor = connection.execute(
                        """
                        UPDATE thread_turns
                        SET status = 'interrupted', rollout_end_ordinal = ?,
                            rollout_end_byte_offset = ?, started_at = ?,
                            completed_at = ?, duration_ms = ?,
                            root_turn_id = COALESCE(root_turn_id, ?)
                        WHERE thread_id = ? AND turn_id = ? AND status = 'inProgress'
                          AND rollout_end_ordinal IS NULL AND rollout_end_byte_offset IS NULL
                          AND rollout_ordinal < ? AND rollout_byte_offset < ?
                          AND (root_turn_id IS NULL OR root_turn_id IS ? OR ? IS NULL)
                        """,
                        (
                            abort.ordinal,
                            abort.end_offset,
                            abort.started_at,
                            abort.completed_at,
                            abort.duration_ms,
                            abort.root_turn_id,
                            finding.thread.thread_id,
                            turn_id,
                            abort.ordinal,
                            abort.end_offset,
                            abort.root_turn_id,
                            abort.root_turn_id,
                        ),
                    )
                    count += cursor.rowcount
            targets = open_file_targets()
            for finding, _ in candidates:
                recheck(finding, targets)
        return backup, count


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("terms", nargs="*", help="title or thread-ID fragments (ANDed)")
    parser.add_argument(
        "--all", action="store_true", help="audit every paginated thread"
    )
    parser.add_argument(
        "--repair", action="store_true", help="realign safe inactive checkpoints"
    )
    parser.add_argument(
        "--repair-loaded-idle",
        action="store_true",
        help="realign a loaded checkpoint past EOF after verifying the thread is idle",
    )
    parser.add_argument(
        "--repair-orphans",
        action="store_true",
        help="restore interrupted status and boundaries from durable abort events",
    )
    parser.add_argument(
        "--codex-home", type=Path, help="override the Codex state directory"
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.repair_loaded_idle and (
        not args.repair or args.all or len(args.terms) != 1
    ):
        raise SystemExit(
            "--repair-loaded-idle requires --repair and one exact thread ID"
        )
    if not args.all and not args.terms:
        raise SystemExit("pass title/ID fragments or --all")
    codex_home = (
        args.codex_home
        or Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex")))
    ).resolve()
    open_targets = open_file_targets()
    state_path = current_versioned(codex_home, "state", open_targets)
    history_path = current_versioned(codex_home, "thread_history", open_targets)
    queue_paths = list(codex_home.glob("queue_*.sqlite"))
    open_queue_paths = [path for path in queue_paths if str(path) in open_targets]
    if len(open_queue_paths) > 1:
        names = ", ".join(str(path) for path in open_queue_paths)
        raise SystemExit(f"multiple open queue databases found: {names}")
    queue_path = (
        open_queue_paths[0]
        if open_queue_paths
        else max(queue_paths, key=lambda path: path.stat().st_mtime_ns)
        if queue_paths
        else None
    )
    state = readonly(state_path)
    history = readonly(history_path)
    queue = readonly(queue_path) if queue_path else None
    try:
        threads = matching_threads(state, tuple(args.terms), args.all)
        if args.repair_loaded_idle and (
            len(threads) != 1 or args.terms[0] != threads[0].thread_id
        ):
            raise SystemExit("--repair-loaded-idle requires one exact thread ID")
        findings = audit(threads, history, queue, open_targets)
    finally:
        state.close()
        history.close()
        if queue is not None:
            queue.close()
    if not threads:
        print("no matching paginated threads")
        return 1
    for finding in findings:
        print_finding(finding)
    if args.repair:
        backup, count = repair(
            history_path, codex_home, findings, args.repair_loaded_idle
        )
        print(f"repaired={count}")
        if backup is not None:
            print(f"backup={backup}")
            print("state=realigned, awaiting normal app-server projection")
    if args.repair_orphans:
        backup, count = repair_orphans(history_path, codex_home, findings)
        print(f"orphaned_turns_repaired={count}")
        if backup is not None:
            print(f"backup={backup}")
    return 0 if findings else 1


if __name__ == "__main__":
    raise SystemExit(main())
