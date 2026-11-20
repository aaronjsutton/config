# Subcommands that accept `--output json` (coder v2.36).
const coder_json_commands = [
    "ai-gateway keys list" "external-auth access-token"
    "external-workspaces agent-instructions" "external-workspaces list"
    "features list" "groups list" "licenses list" "list"
    "organizations list" "organizations members list" "organizations roles show"
    "organizations roles update" "organizations show" "provisioner jobs list"
    "provisioner keys list" "provisioner list" "schedule show" "secret list"
    "speedtest" "stat" "stat cpu" "stat disk" "stat mem" "task list" "task logs"
    "task status" "templates list" "templates presets list"
    "templates versions list" "tokens list" "tokens view" "users list"
    "users oidc-claims" "users show" "version" "whoami"
]

# coder's built-in top-level aliases, expanded first so they also get JSON
# output and defaults.
const coder_aliases = {
    ls: list rm: delete fav: favorite favourite: favorite feature: features
    group: groups license: licenses notification: notifications
    organization: organizations org: organizations orgs: organizations
    tunnel: port-forward prebuild: prebuilds provisioners: provisioner
    pubkey: publickey secrets: secret tasks: task template: templates
    token: tokens unfav: unfavorite unfavourite: unfavorite user: users
}

def coder-expand []: list<string> -> list<string> {
    let args = $in
    if ($args | is-empty) { return $args }
    $args | update 0 {|a| $coder_aliases | get --optional $a | default $a }
}

# Complete via coder's own protocol (what its fish script does): run the
# words so far with COMPLETION_MODE=1. Covers flags, unlike an arg completer.
def complete-coder [place: record] {
    let prev = $place.command | skip 1 | drop 1 | coder-expand
    let current = $place.command | last
    let probe = complete-probe $current
    let candidates = if ($prev | get 0?) == 'until' {
        if ($current | str starts-with '-') {
            [--start -s --tz --dry-run -n --help]
        } else {
            # Workspace names, borrowed from `coder ssh`'s completions.
            coder-complete [ssh ''] | each { split row '.' | first }
        }
    } else if ($prev | is-empty) {
        coder-complete [$probe] | append until
    } else {
        coder-complete [...$prev $probe]
    }
    $candidates | where $it != '' | uniq
}

def coder-complete [words: list<string>] {
    with-env {COMPLETION_MODE: '1'} { ^coder ...$words | complete } | get stdout | lines
}

# Format a coder timestamp as Eastern time: "17:00 ET", or "Sat 17:00 ET"
# when it isn't today. Blank timestamps pass through as null. With --color,
# shade by time left: red under 30m, yellow under 2h, otherwise green.
def coder-et [--color]: [string -> any, nothing -> any] {
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
def coder-strip-owner []: table -> table {
    let rows = $in
    if ($rows | is-empty) { return $rows }
    let owners = $rows | get workspace | each { split row '/' | first } | uniq
    if ($owners | length) > 1 { return $rows }
    $rows | update workspace { str replace -r '^[^/]+/' '' }
}

# Colour a workspace name: orange for ticket-named workspaces (abc-123),
# cyan otherwise.
# Matches after any "owner/" prefix.
def coder-color-workspace []: string -> string {
    let name = $in
    let shade = if (($name | split row '/' | last) =~ '^[a-z]+-\d+$') {
        'xterm_darkorange3b'
    } else {
        'cyan'
    }
    $"(ansi $shade)($name)(ansi reset)"
}

# Show a build status as a coloured bullet; a running workspace that fails
# health checks counts as "unhealthy".
def coder-status [healthy: bool]: string -> string {
    let status = if $in == 'running' and not $healthy { 'unhealthy' } else { $in }
    let shade = match $status {
        'running' => 'green'
        'stopped' | 'deleted' => 'light_gray'
        'failed' | 'canceled' | 'unhealthy' => 'red'
        _ => 'yellow'
    }
    $"(ansi $shade)●(ansi reset)"
}

# Post-processing applied to a command's parsed JSON output.
def coder-defaults [] {
    {
        "schedule show": {||
            select workspace stops_next
            | coder-strip-owner
            | sort-by workspace stops_next
            | update workspace { coder-color-workspace }
            | update stops_next { coder-et --color }
        }
        "list": {||
            let rows = each {|w|
                let running = $w.latest_build.status == 'running'
                let deadline = $w.latest_build.deadline? | default ''
                {
                    "⏻": ($w.latest_build.status | coder-status ($w.health.healthy? | default true))
                    workspace: $"($w.owner_name)/($w.name)"
                    stops_at: (if $running and not ($deadline | str starts-with '0001') { $deadline | coder-et --color })
                    last_used: ($w.last_used_at | into datetime)
                    outdated: $w.outdated
                }
            }
            let rows = $rows | coder-strip-owner | sort-by workspace
            let rows = if ($rows | any { $in.outdated }) { $rows } else { $rows | reject --optional outdated }
            $rows | update workspace { coder-color-workspace }
        }
    }
}

# Longest leading run of words that names a JSON-capable command.
def coder-json-command [args: list<string>]: nothing -> any {
    let words = $args | take while {|a| not ($a | str starts-with '-') }
    $words
    | enumerate
    | each {|w| $words | first ($w.index + 1) | str join ' ' }
    | where $it in $coder_json_commands
    | last
}

# Default coder output to JSON, parsed into nushell data.
@complete complete-coder
def --wrapped coder [...args] {
    let args = $args | coder-expand
    let explicit = $args | any {|a|
        $a in ['-o' '--output' '-h' '--help'] or ($a =~ '^(-o|--output)=')
    }
    let command = coder-json-command $args
    # External calls must be the tail expression of each branch: wrapping one
    # in `return (...)` captures its output, so coder loses the terminal and
    # drops prompts and progress (e.g. `coder create`).
    if ($args | get 0?) == 'until' {
        # Our own command (pkgs/coder-until).
        ^coder-until ...($args | skip 1)
    } else if $command == null or $explicit {
        ^coder ...$args
    } else {
        let output = ^coder ...$args --output json | from json
        let defaults = coder-defaults
        if $command in ($defaults | columns) {
            $output | do ($defaults | get $command)
        } else {
            $output
        }
    }
}
