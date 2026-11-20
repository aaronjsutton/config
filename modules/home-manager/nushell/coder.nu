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

# Complete via coder's own protocol (what its fish script does): run the
# words so far with COMPLETION_MODE=1. Covers flags, unlike an arg completer.
def complete-coder [spans: list<string>] {
    let prev = $spans | skip 1 | drop 1
    let current = $spans | last
    with-env {COMPLETION_MODE: '1'} { ^coder ...$prev $current | complete }
    | get stdout
    | lines
    | where {|c| $c != '' and ($c | str starts-with $current) }
    | uniq
}

# Default coder output to JSON, parsed into nushell data.
@complete complete-coder
def --wrapped coder [...args] {
    let words = $args | take while {|a| not ($a | str starts-with '-') }
    let explicit = $args | any {|a|
        $a in ['-o' '--output' '-h' '--help'] or ($a =~ '^(-o|--output)=')
    }
    let supported = $words | enumerate | any {|w|
        ($words | first ($w.index + 1) | str join ' ') in $coder_json_commands
    }
    if $supported and not $explicit {
        ^coder ...$args --output json | from json
    } else {
        ^coder ...$args
    }
}
