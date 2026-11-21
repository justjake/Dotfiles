---
name: codex-thread-repair
description: Audit or repair local Codex app-server threads with truncated history, stale running turns, or broken fork boundaries while the app server stays up.
---

# Codex thread repair

The rollout JSONL is the canonical record. Preserve it and use the doctor on derived SQLite state only.

## Audit

Find the active Codex home by inspecting the running app server's open SQLite files. Use `--codex-home` if the active home differs from `$CODEX_HOME` or `~/.codex`. Run the bundled script with a thread ID, title fragments, or `--all` for every paginated thread. Audit mode is read-only by default.

```bash
python3 skills/codex-thread-repair/scripts/thread_doctor.py --codex-home CODEX_STATE_DIR THREAD_ID
```

- `healthy` means the saved checkpoint matches the complete rollout and its highest observed ordinal.
- `caught-up-with-anomalies` means the checkpoint matches, with malformed records or invalid ordinals reported separately. Codex can advance past such records.
- `awaiting-projection` means the saved offset already points to the expected record. Check again after a normal app-server resume or durable write.
- `realignable` means a unique expected ordinal can be reached without skipping an earlier unprojected ordinal.
- `loaded` means a potentially inconsistent rollout has an open file descriptor. Consult `thread/read` and distinguish a live turn from an idle recorder.
- `unsafe` means the doctor cannot establish a reliable checkpoint. Inspect the current Codex materializer and the raw record boundaries before drawing conclusions.

An `inProgress` row or a later row by itself does not establish an orphan. Nested turns can legitimately appear before their root turn ends. Check the durable lifecycle and queue.

## Repair

Use mutation flags only when the user authorizes repairs on the affected threads.

- `--repair` moves the byte offset while preserving the ordinal. Open or resume the thread afterward and rerun the audit to verify that Codex projects the remaining records.
- `--repair-orphans` restores interrupted status and both terminal positions from a unique durable abort event in a clean, caught-up rollout. A later turn alone is insufficient. Events with an error payload or competing terminal events require investigation.

Repairs use the Linux Codex writer-lock namespace under `thread-writer-locks/` and refuse active writers and open rollouts. Verify that the running Codex build uses this lock protocol in `codex-rs/rollout/src/writer_lock.rs`. The doctor takes an online backup under `thread-repair-backups/`, then checks rollout identity and the expected SQLite state in a short transaction.

Report the thread IDs, observed checkpoint or turn state, any mutation and backup, and the follow-up audit result. An updated checkpoint can still be awaiting projection.
