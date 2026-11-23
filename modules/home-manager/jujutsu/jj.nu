use @completion@ [complete-probe]
use @display@ ["display add" "display tag"]

def complete-jj [place: record] {
    let typed = $place.command | first | split row ' ' | append ($place.command | skip 1)
    let current = $typed | last
    let words = $typed | drop 1 | append (complete-probe $current)
    with-env {COMPLETE: fish} { ^jj -- ...$words | complete }
    | get stdout
    | lines
    | parse --regex '^(?<value>[^\t]*)(?:\t(?<description>.*))?$'
}

def jj-times [...paths: cell-path]: record -> record {
    let row = $in
    $paths | reduce --fold $row {|p acc| $acc | update $p { into datetime } }
}

def jj-commit-times []: record -> record {
    jj-times $.author.timestamp $.committer.timestamp
}

export def jj-decode [kind: string]: string -> table {
    let rows = lines | each { from json }
    match $kind {
        commit => ($rows | each { jj-commit-times })
        evolog => ($rows | each {|e| $e.commit | jj-commit-times | insert operation ($e.operation | jj-times $.time.start $.time.end) })
        op => ($rows | each { jj-times $.time.start $.time.end })
        workspace => ($rows | each { update target { jj-commit-times } })
        bookmark => ($rows | default null remote | default [] tracking_target)
        _ => $rows
    }
    | display tag $"jj-(if $kind == 'evolog' { 'commit' } else { $kind })"
}

def jj-change []: string -> string {
    $"(ansi magenta_bold)($in | str substring 0..7)(ansi reset)"
}

def jj-commit-id []: string -> string {
    $"(ansi blue)($in | str substring 0..7)(ansi reset)"
}

def jj-op-id []: string -> string {
    $"(ansi blue)($in | str substring 0..11)(ansi reset)"
}

def jj-subject []: string -> string {
    let subject = $in | str trim | lines | get 0? | default ''
    if ($subject | is-empty) { $"(ansi dark_gray)\(no description set\)(ansi reset)" } else { $subject }
}

export-env {
    display add jj-commit {
        table: {|| let rows = $in; if 'change_id' in ($rows | columns) { $rows | move change_id --first } else { $rows } }
        columns: {
            change_id: {|| jj-change }
            commit_id: {|| jj-commit-id }
            description: {|| jj-subject }
            author: {|| get name }
            committer: {|| get timestamp }
            operation: {|| get id | jj-op-id }
        }
        hide: [parents]
        headers: {change_id: change, commit_id: commit, committer: committed}
    }
    display add jj-op {
        columns: {
            id: {|| jj-op-id }
            time: {|| get start }
        }
        hide: [parents hostname username is_snapshot workspace_name attributes]
        headers: {time: started}
    }
    display add jj-bookmark {
        columns: {
            name: {|| $"(ansi magenta)($in)(ansi reset)" }
            target: {|| each { jj-commit-id } | str join ' ' }
            tracking_target: {|| each { jj-commit-id } | str join ' ' }
        }
        headers: {tracking_target: tracking}
    }
    display add jj-workspace {
        columns: {
            target: {|| $"($in.change_id | jj-change) ($in.description | jj-subject)" }
        }
    }
}

@complete complete-jj
export extern main [...args]

@complete complete-jj
@structured [--no-graph -T 'json(self) ++ "\n"'] { jj-decode commit }
export extern "jj log" [...args]

@complete complete-jj
@structured [--no-graph -T 'json(self) ++ "\n"'] { jj-decode evolog }
export extern "jj evolog" [...args]

@complete complete-jj
@structured [--no-graph -T 'json(self) ++ "\n"'] { jj-decode op }
export extern "jj op log" [...args]

@complete complete-jj
@structured [--no-graph -T 'json(self) ++ "\n"'] { jj-decode op }
export extern "jj operation log" [...args]

@complete complete-jj
@structured [-T 'json(self) ++ "\n"'] { jj-decode bookmark }
export extern "jj bookmark list" [...args]

@complete complete-jj
@structured [-T 'json(self) ++ "\n"'] { jj-decode bookmark }
export extern "jj tag list" [...args]

@complete complete-jj
@structured [-T 'json(self) ++ "\n"'] { jj-decode workspace }
export extern "jj workspace list" [...args]

@complete complete-jj
@structured [-T 'json(self) ++ "\n"'] { jj-decode config }
export extern "jj config list" [...args]
