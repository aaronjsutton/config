use @completion@ [complete-probe]

# coder's built-in top-level aliases.
const coder_aliases = {
    ls: list rm: delete fav: favorite favourite: favorite feature: features
    group: groups license: licenses notification: notifications
    organization: organizations org: organizations orgs: organizations
    tunnel: port-forward prebuild: prebuilds provisioners: provisioner
    pubkey: publickey secrets: secret tasks: task template: templates
    token: tokens unfav: unfavorite unfavourite: unfavorite user: users
}

export def coder-expand []: list<string> -> list<string> {
    let args = $in
    if ($args | is-empty) { return $args }
    $args | update 0 {|a| $coder_aliases | get --optional $a | default $a }
}

# Complete via coder's own protocol (what its fish script does): run the
# words so far with COMPLETION_MODE=1. Covers flags, unlike an arg completer.
def complete-coder [place: record] {
    let words = $place.command | first | split row ' ' | append ($place.command | skip 1)
    let prev = $words | skip 1 | drop 1 | coder-expand
    let current = $words | last
    let probe = complete-probe $current
    let candidates = if ($prev | get 0?) == 'until' {
        if ($current | str starts-with '-') {
            [--start -s --tz --dry-run -n --help]
        } else {
            # Workspace names, borrowed from `coder ssh`'s completions.
            coder-complete [ssh ''] | each { split row '.' | first }
        }
    } else if ($prev | is-empty) {
        coder-complete [$probe] | append [until view]
    } else {
        coder-complete [...$prev $probe]
    }
    $candidates | where $it != '' | uniq
}

def coder-complete [words: list<string>] {
    with-env {COMPLETION_MODE: '1'} { ^coder ...$words | complete } | get stdout | lines
}

def coder-time []: [string -> any, nothing -> any] {
    let raw = $in
    if ($raw | is-empty) or ($raw | str starts-with '0001') { return null }
    $raw | into datetime
}

export def coder-decode-list []: string -> table {
    from json
    | each {|w|
        let build = $w.latest_build
        let running = $build.status == 'running'
        let healthy = $w.health.healthy? | default true
        {
            status: (if $running and not $healthy { 'unhealthy' } else { $build.status })
            workspace: $"($w.owner_name)/($w.name)"
            outdated: $w.outdated
            stops_at: (if $running { $build.deadline? | coder-time })
            last_used: ($w.last_used_at | coder-time)
        }
    }
    | sort-by workspace
}

export def coder-decode-schedule []: string -> table {
    from json
    | select workspace stops_next
    | update stops_next { coder-time }
    | sort-by workspace stops_next
}

# Format a time as Eastern time: "17:00 ET", or "Sat 17:00 ET" when it isn't
# today. Null passes through. With --color, shade by time left: red under
# 30m, yellow under 2h, otherwise green.
export def coder-et [--color]: [datetime -> any, string -> any, nothing -> any] {
    let raw = $in
    if ($raw | is-empty) { return null }
    let t = $raw | into datetime | date to-timezone America/New_York
    let today = date now | date to-timezone America/New_York | format date '%F'
    let text = $t | format date (if ($t | format date '%F') == $today { '%H:%M ET' } else { '%a %H:%M ET' })
    if not $color { return $text }
    let left = $t - (date now)
    let shade = if $left < 30min { 'red' } else if $left < 2hr { 'yellow' } else { 'green' }
    $"(ansi $shade)($text)(ansi reset)"
}

# Drop the "owner/" prefix from workspace names when every row shares one
# owner (the default owner:me search); keep it when owners are mixed.
export def coder-strip-owner []: table -> table {
    let rows = $in
    if ($rows | is-empty) { return $rows }
    let owners = $rows | get workspace | each { split row '/' | first } | uniq
    if ($owners | length) > 1 { return $rows }
    $rows | update workspace { str replace -r '^[^/]+/' '' }
}

# Colour a workspace name: orange for ticket-named workspaces (abc-123),
# cyan otherwise.
# Matches after any "owner/" prefix.
export def coder-color-workspace []: string -> string {
    let name = $in
    let shade = if (($name | split row '/' | last) =~ '^[a-z]+-\d+$') {
        'xterm_darkorange3b'
    } else {
        'cyan'
    }
    $"(ansi $shade)($name)(ansi reset)"
}

# Show a build status as a coloured glyph.
export def coder-status [outdated: bool = false]: string -> string {
    let style = match [$in $outdated] {
        ['running' true] => ['◐' 'light_blue']
        ['stopped' true] => ['◌' 'light_blue']
        ['running' _] => ['●' 'green']
        ['starting' _] => ['○' 'green']
        ['stopping' _] => ['○' 'dark_gray']
        ['stopped' _] => ['◌' 'dark_gray']
        ['canceling' _] => ['○' 'red']
        ['canceled' _] => ['◌' 'red']
        ['failed' _] => ['◉' 'red']
        ['unhealthy' _] => ['◉' 'yellow']
        ['deleting' _] => ['○' 'red']
        ['deleted' _] => ['◌' 'dark_gray']
        _ => ['○' 'yellow']
    }
    $"(ansi $'($style.1)_bold')($style.0)(ansi reset)"
}

export def "coder view" []: table -> table {
    let rows = $in
    let has = {|c| $c in ($rows | columns) }
    $rows
    | if (do $has workspace) { coder-strip-owner | update workspace { coder-color-workspace } } else { $in }
    | if (do $has status) { update status {|r| $r.status | coder-status ($r.outdated? | default false) } } else { $in }
    | if (do $has outdated) { reject outdated } else { $in }
    | if (do $has stops_at) { update stops_at { coder-et --color } } else { $in }
    | if (do $has stops_next) { update stops_next { coder-et --color } } else { $in }
    | if (do $has status) { metadata set {|m| $m | merge {headers: {status: (char --unicode '23fb')}} } } else { $in }
}

@complete complete-coder
export def --wrapped "coder until" [...args] {
    ^coder-until ...$args
}

@complete complete-coder
export extern main [...args]

@complete complete-coder
@structured [--output json] { coder-decode-list }
export extern "coder list" [...args]

@complete complete-coder
@structured [--output json] { coder-decode-list }
export extern "coder ls" [...args]

@complete complete-coder
@structured [--output json] { coder-decode-schedule }
export extern "coder schedule show" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder ai-gateway keys list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder external-auth access-token" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder external-workspaces agent-instructions" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder external-workspaces list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder features list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder groups list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder licenses list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder organizations list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder organizations members list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder organizations roles show" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder organizations roles update" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder organizations show" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder provisioner jobs list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder provisioner keys list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder provisioner list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder secret list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder speedtest" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder stat" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder stat cpu" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder stat disk" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder stat mem" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder task list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder task logs" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder task status" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder templates list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder templates presets list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder templates versions list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder tokens list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder tokens view" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder users list" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder users oidc-claims" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder users show" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder version" [...args]

@complete complete-coder
@structured [--output json] { from json }
export extern "coder whoami" [...args]
