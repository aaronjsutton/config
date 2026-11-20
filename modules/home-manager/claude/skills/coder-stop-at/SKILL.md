---
name: coder-stop-at
description: List running Coder workspaces and set them to stop at a specific clock time today (default 17:30 ET). Use when the user wants to list running Coder workspaces, or schedule, extend, or override when they stop at a given time, e.g. "stop my workspaces at 5:30".
---

# Stop Coder workspaces at a set time

Use the `coder-until` command (also `coder until` in nushell). It sets each
workspace's current stop time to an exact clock time, starting named
workspaces first if they're stopped.

```sh
coder-until [TIME] [WORKSPACE...] [--start] [--tz ZONE] [--dry-run]
```

- `TIME` is `HH:MM[:SS]` today, or an ISO datetime such as `2026-11-21T09:00:00`
  for another day. Default `17:30:00`, read in `America/New_York` unless `--tz`
  is given or the time carries an offset.
- With no workspaces it changes all of the user's **running** workspaces.
  `--start` also starts their stopped ones. Named workspaces (owner prefix
  optional) are started if stopped.
- `--dry-run` shows the plan without changing anything.

## Steps

1. If the request is ambiguous (which workspaces, whether to start stopped
   ones), run with `--dry-run` first and show the user the table.
2. Run it with the user's time and workspaces, e.g. `coder-until 17:00` or
   `coder-until 18:15 abc-123`.
3. Relay the table it prints (workspace, previous stop, new stop, note).

## Limits

- The target must be at least 30 minutes away. The command refuses otherwise.
  Tell the user; don't pick a different time on your own.
- The template may cap runtime. Failures appear in the `note` column and the
  command exits non-zero. Report them.
- This changes only the current build. The workspace's usual auto-stop still
  applies to future starts.
