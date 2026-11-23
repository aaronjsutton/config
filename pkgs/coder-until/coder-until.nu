
# Keep Coder workspaces running until a set time.
#
# TIME is HH:MM[:SS] today, or an ISO datetime such as 2026-11-21T09:00:00
# (read in --tz unless it carries an offset). It must be at least 30 minutes
# away. Named workspaces are started first if stopped; with no names, only
# running workspaces change unless --start is given.
export def main [
    time: string = "17:30:00"            # HH:MM[:SS] or ISO datetime
    ...workspaces: string                # my workspaces (owner/ optional); default: all running
    --start (-s)                         # also start my stopped workspaces
    --tz: string = "America/New_York"    # zone for TIME and the report
    --dry-run (-n)                       # show what would change, touch nothing
] {
    # Let `coder-until abc-123` mean the default time for abc-123.
    let looks_like_time = looks-like-time $time
    let names = if $looks_like_time { $workspaces } else { $workspaces | prepend $time }
    let target = if $looks_like_time { resolve $time $tz } else { resolve "17:30:00" $tz }

    let left = $target - (date now)
    if $left < 30min {
        let when = if $left <= 0sec {
            'has already passed'
        } else {
            $"is only (($left / 1min) | math floor) minutes away"
        }
        error make --unspanned {
            msg: $"(fmt $target $tz) ($when); coder needs at least 30 minutes."
        }
    }

    let all = @coder@ list --output json | from json
    let mine = $all | each {|w| {
        name: $w.name
        owner: $w.owner_name
        status: $w.latest_build.status
        deadline: ($w.latest_build.deadline? | default '')
    } }

    let wanted = if ($names | is-empty) {
        $mine | where {|w| $w.status == 'running' or ($start and $w.status == 'stopped') }
    } else {
        let short = $names | each { split row '/' | last }
        let unknown = $short | where {|n| $n not-in $mine.name }
        if ($unknown | is-not-empty) {
            error make --unspanned { msg: $"Unknown workspace: ($unknown | str join ', ')" }
        }
        $mine | where name in $short
    }
    if ($wanted | is-empty) {
        print "No matching workspaces. Pass names, or --start to include stopped ones."
        return
    }

    let results = $wanted | each {|w| apply $w $target $dry_run }

    # Re-read deadlines so the report shows what coder actually set.
    let after = if $dry_run { [] } else { @coder@ list --output json | from json }
    let report = $results | each {|r|
        let now = if $dry_run {
            if $r.ok { $target } else { null }
        } else {
            $after | where name == $r.name | get 0?.latest_build?.deadline? | parse-deadline
        }
        {
            workspace: $r.name
            was: ($r.was | parse-deadline | fmt-or-dash $tz)
            now: ($now | fmt-or-dash $tz)
            note: $r.note
        }
    }
    print ($report | table --index false)
    if ($results | any { not $in.ok }) { exit 1 }
}

export def looks-like-time [s: string]: nothing -> bool {
    $s =~ '^\d{1,2}:\d{2}(:\d{2})?$' or $s =~ '^\d{4}-\d{2}-\d{2}T'
}

# Start (if needed) and extend one workspace; returns {name was ok note}.
def apply [w: record, target: datetime, dry_run: bool] {
    let ref = $"($w.owner)/($w.name)"
    let base = {name: $w.name, was: (if $w.status == 'running' { $w.deadline } else { '' })}
    if $w.status not-in ['running' 'stopped'] {
        return ($base | merge {ok: false, note: $"skipped: ($w.status)"})
    }
    let starting = $w.status == 'stopped'
    if $dry_run {
        return ($base | merge {ok: true, note: (if $starting { 'would start' } else { 'would extend' })})
    }
    if $starting {
        let r = @coder@ start --yes $ref | complete
        if $r.exit_code != 0 {
            return ($base | merge {ok: false, note: $"start failed: (last-line $r)"})
        }
    }
    # Seconds remaining, computed right before the call so every workspace
    # lands on the same time.
    let secs = (($target - (date now)) / 1sec | math ceil)
    let r = @coder@ schedule extend $ref $"($secs)s" | complete
    if $r.exit_code != 0 {
        return ($base | merge {ok: false, note: $"extend failed: (last-line $r)"})
    }
    $base | merge {ok: true, note: (if $starting { 'started' } else { '' })}
}

# Interpret TIME as an instant. Times without an offset are read in `tz`.
export def resolve [time: string, tz: string]: nothing -> datetime {
    if $time =~ '(Z|[+-]\d{2}:?\d{2})$' { return ($time | into datetime) }
    let naive = if $time =~ '^\d{4}-' {
        $time
    } else {
        let hms = if ($time | split row ':' | length) == 2 { $"($time):00" } else { $time }
        let hms = if ($hms =~ '^\d:') { $"0($hms)" } else { $hms }
        $"(date now | date to-timezone $tz | format date '%F')T($hms)"
    }
    # The zone's UTC offset at that time.
    let guess = $"($naive)Z" | into datetime | date to-timezone $tz | format date '%:z'
    let offset = $"($naive)($guess)" | into datetime | date to-timezone $tz | format date '%:z'
    $"($naive)($offset)" | into datetime
}

export def parse-deadline []: any -> any {
    let d = $in
    if ($d | is-empty) or ($d | str starts-with '0001') { null } else { $d | into datetime }
}

# "17:30 ET", or "Sat 17:30 ET" when not today.
export def fmt [t: datetime, tz: string]: nothing -> string {
    let local = $t | date to-timezone $tz
    let zone = if $tz == 'America/New_York' { 'ET' } else { $local | format date '%Z' }
    let today = date now | date to-timezone $tz | format date '%F'
    let day = if ($local | format date '%F') == $today { '' } else { $local | format date '%a ' }
    $"($day)($local | format date '%H:%M') ($zone)"
}

export def fmt-or-dash [tz: string]: any -> string {
    if $in == null { '—' } else { fmt $in $tz }
}

export def last-line [r: record]: nothing -> string {
    [$r.stderr $r.stdout] | str join "\n" | lines | where $it != '' | last | default 'unknown error'
}
