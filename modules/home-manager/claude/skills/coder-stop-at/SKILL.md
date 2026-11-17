---
name: coder-stop-at
description: List running Coder workspaces and set them to stop at a specific clock time today (default 17:30 ET). Use when the user wants to list running Coder workspaces, or schedule, extend, or override when they stop at a given time, e.g. "stop my workspaces at 5:30".
---

# Stop Coder workspaces at a set time

The time defaults to **17:30:00 America/New_York** today. If the user names a different time, time zone, or set of workspaces, use those instead.

## 1. List running workspaces

```sh
coder list --search "status:running" -o json \
  | jq -r '.[] | [.owner_name + "/" + .name, .latest_build.deadline] | @tsv'
```

Show the user the workspaces and their current stop times (`deadline` is in UTC; convert it to ET). If none are running, say so and stop.

## 2. Override the stop time

`coder schedule extend <workspace> <duration>` (alias `override-stop`) sets this build's stop time to **now + duration**. It does not accept a clock time, so work out the seconds remaining **right before each call**. That keeps each workspace on the exact target time:

```sh
target=$(TZ=America/New_York date -j -f "%Y-%m-%d %H:%M:%S" "$(date +%Y-%m-%d) 17:30:00" +%s)
for ws in <workspace names>; do
  coder schedule extend "$ws" "$(( target - $(date +%s) ))s"
done
```

(`date -j -f` is BSD/macOS syntax.)

Limits:
- The new stop time has to be at least 30 minutes away. If the target is closer than that, or already past, tell the user. Don't pick a different time on your own.
- The template may cap the maximum runtime. If `extend` fails, report the error.

## 3. Verify and report

List again and convert each `deadline` to ET:

```sh
coder list --search "status:running" -o json | jq -r '.[] | [.name, .latest_build.deadline] | @tsv' \
  | while IFS=$'\t' read -r n dl; do
      s=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "${dl%%.*}" +%s)
      echo "$n  $(TZ=America/New_York date -r "$s" '+%Y-%m-%d %H:%M:%S %Z')"
    done
```

Report a table with each workspace's previous and new stop times. Mention that this only changes the current build. The workspace's usual auto-stop (`STOPS AFTER`) still applies to future starts.
