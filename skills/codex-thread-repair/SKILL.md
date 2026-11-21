---
name: codex-thread-repair
description: Diagnose and repair Codex app-server chat threads whose UI shows only early turns, stays running after interruption, or queues new messages as steering. Use for stuck, truncated, unresumable, or unforkable local Codex conversations when the app server must remain running.
---

# Codex thread repair

Preserve the rollout JSONL as canonical evidence. Repair derived SQLite state in place without restarting or killing the app server.

## Diagnose first

1. Find the local Codex checkout before consulting the internet. Inspect the running app-server executable and nearby source checkouts. Read the current implementations of:
   - `codex-rs/thread-store/src/local/live_writer.rs`
   - `codex-rs/thread-store/src/local/thread_history_materialization.rs`
   - `codex-rs/thread-store/src/local/thread_history.rs`
   - `codex-rs/thread-store/src/local/paginated_fork.rs` when forking is affected
2. Discover the active versioned databases under `${CODEX_HOME:-$HOME/.codex}`. Do not assume a database suffix when multiple versions exist; correlate the newest files with the running process's open file descriptors.
3. Run the bundled doctor in audit mode. Pass remembered title fragments to narrow the result, or use `--all` for a complete paginated-thread invariant check:

   ```bash
   mise exec -- python skills/codex-thread-repair/scripts/thread_doctor.py THREAD_ID
   mise exec -- python skills/codex-thread-repair/scripts/thread_doctor.py --all
   ```

4. Distinguish these states:
   - `healthy`: the projection byte offset equals the rollout size, the file ends on a complete JSONL record, and the final raw ordinal is immediately before the saved next ordinal.
   - `loaded`: a process has the rollout open. This does not prove that a turn is running, but direct repair is refused by default because the doctor cannot coordinate with that writer.
   - `realignable`: the saved next ordinal occurs exactly once at a complete JSONL line boundary, but the saved byte offset points elsewhere. This covers duplicate-ordinal restart records and rollout compaction that changes byte positions.
   - `awaiting-projection`: the pointer is already realigned, but the app server has not yet projected the remaining suffix.
   - `unsafe`: the expected ordinal is missing or ambiguous, the rollout has malformed lines, or the state changed during inspection. Stop and investigate; never guess an offset.
   - `orphaned turn`: SQLite says `inProgress` although a later projected turn exists or the raw lifecycle proves termination. Treat this separately from a projection checkpoint fault.

Check `queue_*.sqlite` for queued items, but do not delete user messages as a first-line repair.

## Repair a projection checkpoint

Use `--repair` only after the user has authorized fixing the affected local threads:

```bash
mise exec -- python skills/codex-thread-repair/scripts/thread_doctor.py THREAD_ID --repair
```

The doctor must leave loaded and unsafe threads unchanged by default. For each realignable unloaded thread, it:

1. Creates a consistent SQLite online backup under `$CODEX_HOME/thread-repair-backups/`.
2. Starts `BEGIN IMMEDIATE` only after all JSONL discovery is complete.
3. Updates only `next_rollout_byte_offset`, keeping `next_rollout_ordinal` unchanged.
4. Uses the old offset and ordinal as compare-and-swap predicates so concurrent app-server progress makes the repair fail safely.
5. Re-scans file identity, size, modification time, completeness, and expected-ordinal position immediately before mutation, then re-checks the raw signatures before commit.
6. Commits all selected checkpoint updates in one short transaction and re-verifies each pointer.

An open file can be an idle loaded recorder rather than a running turn. If the thread is stuck while loaded, first verify through `thread/read` that it is idle and disconnect the UI client if practical. Only then use `--repair-loaded-stable`; this explicit override still requires stable repeated raw-file observations and the SQLite compare-and-swap. Never use it while a turn, compaction, or resume is changing the rollout.

Do not edit, truncate, renumber, or replace rollout JSONL. Do not delete and rebuild projected history while the app server is live. Do not update a checkpoint past an ordinal that has not already been projected.

Once the pointer is realigned, opening/resuming the thread or its next normal durable write lets the app server project the remaining rollout suffix. Re-run the doctor afterward and require `healthy` before considering the history fixed.

## Clear a stale running marker

First repair and fully catch up the projection. Then inspect `thread_turns`, the raw task lifecycle events, live rollout file descriptors, and the queue. Change an `inProgress` row to `interrupted` only when all of these are true:

- no process has the rollout open;
- the raw file is stable rather than actively growing;
- a later turn exists, or raw terminal evidence makes the stale status unambiguous;
- a fresh SQLite backup exists; and
- the update predicates include `status = 'inProgress'` and the exact `turn_id`.

Do not synthesize a final assistant item. An interrupted turn legitimately may have none. This distinction matters for forking: the backend can fork through an interrupted turn, while a UI may disable a message-level fork when the preceding assistant item does not exist. Prefer a turn boundary or `beforeTurnId` where the client supports it.

The doctor's `--repair-orphans` flag implements the narrow, mechanically provable subset: threads whose projections are fully caught up and whose stale `inProgress` turn has a later projected turn. It backs up the database and uses compare-and-swap predicates. Loaded threads remain excluded unless the same explicit `--repair-loaded-stable` idle-verification policy is supplied. Investigate ambiguous final turns manually rather than broadening this rule.

```bash
mise exec -- python skills/codex-thread-repair/scripts/thread_doctor.py --all --repair-orphans
mise exec -- python skills/codex-thread-repair/scripts/thread_doctor.py THREAD_ID --repair-orphans --repair-loaded-stable
```

## Verify and report

Report the matched thread IDs and names, which invariant failed, every mutation, the backup path, whether the projection has caught up, any remaining stale turn or queued message, and whether a live active thread was deliberately excluded. Never claim a thread is repaired merely because its checkpoint was changed; distinguish `realigned, awaiting projection` from `healthy`.
