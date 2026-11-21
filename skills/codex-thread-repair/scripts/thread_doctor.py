#!/usr/bin/env python3
"""Audit and narrowly repair Codex paginated-thread projection checkpoints."""

# ruff: noqa: T201 -- this is an operator-facing command-line diagnostic.

from __future__ import annotations

import argparse
import json
import os
import sqlite3
from collections.abc import Iterable
from contextlib import suppress
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path


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
    last_ordinal: int | None
    complete_final_line: bool
    stable_scan: bool
    file_signature: tuple[int, int, int, int]

    @property
    def checkpoint_consistent(self) -> bool:
        return (
            self.old_offset == self.rollout_size
            and self.malformed_lines == 0
            and self.complete_final_line
            and self.last_ordinal is not None
            and self.expected_ordinal == self.last_ordinal + 1
        )

    @property
    def can_realign(self) -> bool:
        return (
            self.stable_scan
            and self.malformed_lines == 0
            and self.complete_final_line
            and len(self.expected_positions) == 1
            and self.expected_positions[0] != self.old_offset
        )

    @property
    def status(self) -> str:
        if self.checkpoint_consistent:
            return "healthy"
        if self.loaded:
            return "loaded"
        if not self.stable_scan or self.malformed_lines or not self.complete_final_line:
            return "unsafe"
        if len(self.expected_positions) == 1:
            if self.expected_positions[0] == self.old_offset:
                return "awaiting-projection"
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
    connection = sqlite3.connect(f"file:{path}?mode=ro", uri=True)
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


def scan_rollout(
    path: Path, expected: int
) -> tuple[tuple[int, ...], int, int | None, bool, bool, tuple[int, int, int, int]]:
    before = file_signature(path)
    positions: list[int] = []
    malformed = 0
    last_ordinal: int | None = None
    final_line = b""
    with path.open("rb") as rollout:
        while line := rollout.readline():
            final_line = line
            position = rollout.tell() - len(line)
            try:
                value = json.loads(line)
            except (json.JSONDecodeError, UnicodeDecodeError):
                malformed += 1
                continue
            if value.get("ordinal") == expected:
                positions.append(position)
            ordinal = value.get("ordinal")
            if isinstance(ordinal, int):
                last_ordinal = ordinal
    after = file_signature(path)
    return (
        tuple(positions),
        malformed,
        last_ordinal,
        bool(final_line) and final_line.endswith(b"\n"),
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
        (
            positions,
            malformed,
            last_ordinal,
            complete_final_line,
            stable_scan,
            signature,
        ) = scan_rollout(thread.rollout_path, expected)
        size = signature[2]
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
                rollout_size=size,
                expected_positions=positions,
                malformed_lines=malformed,
                loaded=str(thread.rollout_path) in open_targets,
                queued_items=count_queued(queue, thread.thread_id),
                in_progress_turns=in_progress,
                last_ordinal=last_ordinal,
                complete_final_line=complete_final_line,
                stable_scan=stable_scan,
                file_signature=signature,
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


def repair(
    history_path: Path,
    codex_home: Path,
    findings: Iterable[Finding],
    repair_loaded_stable: bool,
) -> tuple[Path | None, int]:
    selected = [
        finding
        for finding in findings
        if finding.can_realign and (not finding.loaded or repair_loaded_stable)
    ]
    if not selected:
        return None, 0
    # Refresh every rollout observation after the potentially long initial audit.
    refreshed: list[Finding] = []
    history_read = readonly(history_path)
    try:
        for finding in selected:
            current = audit(
                [finding.thread], history_read, None, open_file_targets()
            )[0]
            if (
                not current.can_realign
                or current.old_offset != finding.old_offset
                or current.expected_ordinal != finding.expected_ordinal
                or current.new_offset != finding.new_offset
                or (current.loaded and not repair_loaded_stable)
            ):
                raise RuntimeError(
                    f"rollout state changed for {finding.thread.thread_id}; refusing repair"
                )
            refreshed.append(current)
    finally:
        history_read.close()
    backup = backup_database(history_path, codex_home, "checkpoint-repair")
    connection = sqlite3.connect(history_path, timeout=5.0)
    try:
        connection.execute("BEGIN IMMEDIATE")
        current_open_targets = open_file_targets()
        for finding in refreshed:
            if file_signature(finding.thread.rollout_path) != finding.file_signature:
                raise RuntimeError(
                    f"rollout changed for {finding.thread.thread_id}; rolled back"
                )
            if (
                str(finding.thread.rollout_path) in current_open_targets
                and not repair_loaded_stable
            ):
                raise RuntimeError(
                    f"rollout became loaded for {finding.thread.thread_id}; rolled back"
                )
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
                    f"projection state changed for {finding.thread.thread_id}; rolled back"
                )
        for finding in refreshed:
            actual = connection.execute(
                """
                SELECT next_rollout_byte_offset, next_rollout_ordinal
                FROM thread_history_projection_state WHERE thread_id = ?
                """,
                (finding.thread.thread_id,),
            ).fetchone()
            if actual != (finding.new_offset, finding.expected_ordinal):
                raise RuntimeError(
                    f"checkpoint verification failed for {finding.thread.thread_id}"
                )
        final_open_targets = open_file_targets()
        for finding in refreshed:
            if file_signature(finding.thread.rollout_path) != finding.file_signature:
                raise RuntimeError(
                    f"rollout changed for {finding.thread.thread_id}; rolled back"
                )
            if (
                str(finding.thread.rollout_path) in final_open_targets
                and not repair_loaded_stable
            ):
                raise RuntimeError(
                    f"rollout became loaded for {finding.thread.thread_id}; rolled back"
                )
        connection.commit()
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()
    return backup, len(refreshed)


def repair_orphans(
    history_path: Path,
    codex_home: Path,
    findings: Iterable[Finding],
    repair_loaded_stable: bool,
) -> tuple[Path | None, int]:
    healthy = {
        finding.thread.thread_id: finding
        for finding in findings
        if finding.status == "healthy"
        and (not finding.loaded or repair_loaded_stable)
    }
    if not healthy:
        return None, 0
    refreshed: dict[str, Finding] = {}
    history_read = readonly(history_path)
    try:
        for thread_id, finding in healthy.items():
            current = audit(
                [finding.thread], history_read, None, open_file_targets()
            )[0]
            if (
                current.status != "healthy"
                or (current.loaded and not repair_loaded_stable)
                or current.file_signature != finding.file_signature
            ):
                continue
            refreshed[thread_id] = current
    finally:
        history_read.close()
    if not refreshed:
        return None, 0
    connection = sqlite3.connect(history_path, timeout=5.0)
    candidates: list[tuple[str, str, int]] = []
    try:
        for thread_id in sorted(refreshed):
            candidates.extend(
                (row[0], row[1], int(row[2]))
                for row in connection.execute(
                    """
                    SELECT old.thread_id, old.turn_id, old.rollout_ordinal
                    FROM thread_turns AS old
                    WHERE old.thread_id = ? AND old.status = 'inProgress'
                      AND EXISTS (
                        SELECT 1 FROM thread_turns AS later
                        WHERE later.thread_id = old.thread_id
                          AND later.rollout_ordinal > old.rollout_ordinal
                      )
                    """,
                    (thread_id,),
                )
            )
    finally:
        connection.close()
    if not candidates:
        return None, 0
    backup = backup_database(history_path, codex_home, "orphan-repair")
    connection = sqlite3.connect(history_path, timeout=5.0)
    try:
        connection.execute("BEGIN IMMEDIATE")
        current_open_targets = open_file_targets()
        for thread_id in {candidate[0] for candidate in candidates}:
            finding = refreshed[thread_id]
            if (
                str(finding.thread.rollout_path) in current_open_targets
                and not repair_loaded_stable
            ) or (
                file_signature(finding.thread.rollout_path) != finding.file_signature
            ):
                raise RuntimeError(f"rollout changed for {thread_id}; rolled back")
        for thread_id, turn_id, ordinal in candidates:
            cursor = connection.execute(
                """
                UPDATE thread_turns SET status = 'interrupted'
                WHERE thread_id = ? AND turn_id = ?
                  AND rollout_ordinal = ? AND status = 'inProgress'
                """,
                (thread_id, turn_id, ordinal),
            )
            if cursor.rowcount != 1:
                raise RuntimeError(
                    f"turn state changed for {thread_id}/{turn_id}; rolled back"
                )
        final_open_targets = open_file_targets()
        for thread_id in {candidate[0] for candidate in candidates}:
            finding = refreshed[thread_id]
            if (
                str(finding.thread.rollout_path) in final_open_targets
                and not repair_loaded_stable
            ) or (
                file_signature(finding.thread.rollout_path) != finding.file_signature
            ):
                raise RuntimeError(f"rollout changed for {thread_id}; rolled back")
        connection.commit()
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()
    return backup, len(candidates)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("terms", nargs="*", help="title or thread-ID fragments (ANDed)")
    parser.add_argument("--all", action="store_true", help="audit every paginated thread")
    parser.add_argument(
        "--repair", action="store_true", help="realign safe inactive checkpoints"
    )
    parser.add_argument(
        "--repair-loaded-stable",
        action="store_true",
        help="allow checkpoint repair for a loaded rollout after explicit idle verification",
    )
    parser.add_argument(
        "--repair-orphans",
        action="store_true",
        help="interrupt inactive caught-up turns that have later projected turns",
    )
    parser.add_argument("--codex-home", type=Path, help="override the Codex state directory")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if not args.all and not args.terms:
        raise SystemExit("pass title/ID fragments or --all")
    codex_home = args.codex_home or Path(
        os.environ.get("CODEX_HOME", str(Path.home() / ".codex"))
    )
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
            history_path, codex_home, findings, args.repair_loaded_stable
        )
        print(f"repaired={count}")
        if backup is not None:
            print(f"backup={backup}")
            print("state=realigned, awaiting normal app-server projection")
    if args.repair_orphans:
        backup, count = repair_orphans(
            history_path, codex_home, findings, args.repair_loaded_stable
        )
        print(f"orphaned_turns_repaired={count}")
        if backup is not None:
            print(f"backup={backup}")
    return 0 if findings else 1


if __name__ == "__main__":
    raise SystemExit(main())
