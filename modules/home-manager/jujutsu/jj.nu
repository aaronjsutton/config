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

const jj_painted = {
    commit: [change_id commit_id description author committer]
    op: [id time description]
    bookmark: [name remote target]
}

const jj_tail = ') ++ "\t" ++ json(self) ++ "\n"'

const jj_log_label = 'separate(" ", if(current_working_copy, "working_copy"), if(immutable, "immutable", "mutable"), if(conflict, "conflicted"))'
const jj_log_fields = [
    'format_short_change_id_with_change_offset(self)'
    'format_short_commit_id(commit_id)'
    'if(description, description.first_line(), label(if(empty, "empty"), description_placeholder))'
    'format_short_signature(author)'
    'format_timestamp(commit_timestamp(self))'
]
const jj_log_template = $"label\(($jj_log_label), " + ($jj_log_fields | str join $"\) ++ \"\\t\" ++ label\(($jj_log_label), ") + $jj_tail

const jj_evolog_label = 'separate(" ", if(commit.current_working_copy(), "working_copy"), if(commit.immutable(), "immutable", "mutable"), if(commit.conflict(), "conflicted"))'
const jj_evolog_fields = [
    'format_short_change_id_with_change_offset(commit)'
    'format_short_commit_id(commit.commit_id())'
    'if(commit.description(), commit.description().first_line(), label(if(commit.empty(), "empty"), description_placeholder))'
    'format_short_signature(commit.author())'
    'format_timestamp(commit_timestamp(commit))'
]
const jj_evolog_template = $"label\(($jj_evolog_label), " + ($jj_evolog_fields | str join $"\) ++ \"\\t\" ++ label\(($jj_evolog_label), ") + $jj_tail

const jj_op_label = 'if(current_operation, "current_operation")'
const jj_op_fields = ['format_short_operation_id(id)' 'time.start().ago()' 'description.first_line()']
const jj_op_template = $"label\(($jj_op_label), " + ($jj_op_fields | str join $"\) ++ \"\\t\" ++ label\(($jj_op_label), ") + $jj_tail

const jj_bookmark_fields = [
    'label("bookmark", name)'
    'if(remote, label("bookmark", "@" ++ remote))'
    'if(conflict, label("conflict", "(conflicted)"), if(normal_target, format_short_commit_id(normal_target.commit_id())))'
]
const jj_bookmark_template = 'concat(' + ($jj_bookmark_fields | str join ') ++ "\t" ++ concat(') + $jj_tail
const jj_tag_template = ($jj_bookmark_template | str replace --all '"bookmark"' '"tag"')

def jj-key [kind: string]: record -> string {
    let row = $in
    match $kind {
        op => ($row.id? | default '')
        bookmark => $"($row.name? | default '')@($row.remote? | default '')"
        _ => ($row.commit_id? | default '')
    }
}

export def jj-decode [kind: string]: string -> table {
    let lines = lines | each { split row "\t" }
    let painted = $lines | each { drop 1 }
    let rows = $lines | each { last | from json }
    let rows = match $kind {
        commit => ($rows | each { jj-commit-times })
        evolog => ($rows | each {|e| $e.commit | jj-commit-times | insert operation ($e.operation | jj-times $.time.start $.time.end) })
        op => ($rows | each { jj-times $.time.start $.time.end })
        workspace => ($rows | each { update target { jj-commit-times } })
        bookmark => ($rows | default null remote | default [] tracking_target)
        _ => $rows
    }
    let base = if $kind == 'evolog' { 'commit' } else { $kind }
    let columns = $jj_painted | get --optional $base | default []
    let colors = $rows | zip $painted | where ($columns | is-not-empty) and ($it.1 | length) == ($columns | length) | reduce --fold {} {|pair acc|
        $acc | upsert ($pair.0 | jj-key $base) ($columns | zip $pair.1 | reduce --fold {} {|kv r| $r | insert $kv.0 $kv.1 })
    }
    $rows
    | display tag $"jj-($base)"
    | metadata set {|m| if ($colors | is-empty) { $m } else { $m | merge {jj_colors: $colors} } }
}

def jj-paint [kind: string, row: record, meta: record, column: string, fallback: closure]: any -> any {
    let cell = $in
    let painted = $meta.jj_colors? | default {} | get --optional ($row | jj-key $kind) | default {} | get --optional $column
    if $painted == null { $cell | do $fallback } else { $painted }
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
            change_id: {|r m| jj-paint commit $r $m change_id {|| jj-change } }
            commit_id: {|r m| jj-paint commit $r $m commit_id {|| jj-commit-id } }
            description: {|r m| jj-paint commit $r $m description {|| jj-subject } }
            author: {|r m| jj-paint commit $r $m author {|| get email } }
            committer: {|r m| jj-paint commit $r $m committer {|| get timestamp } }
            operation: {|| get id | jj-op-id }
        }
        hide: [parents]
        headers: {change_id: change, commit_id: commit, committer: committed}
    }
    display add jj-op {
        columns: {
            id: {|r m| jj-paint op $r $m id {|| jj-op-id } }
            time: {|r m| jj-paint op $r $m time {|| get start } }
            description: {|r m| jj-paint op $r $m description {|| $in } }
        }
        hide: [parents hostname username is_snapshot workspace_name attributes]
        headers: {time: started}
    }
    display add jj-bookmark {
        columns: {
            name: {|r m| jj-paint bookmark $r $m name {|| $"(ansi magenta)($in)(ansi reset)" } }
            remote: {|r m| jj-paint bookmark $r $m remote {|| $in } }
            target: {|r m| jj-paint bookmark $r $m target {|| each { jj-commit-id } | str join ' ' } }
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
@structured [--color always --no-graph -T $jj_log_template] { jj-decode commit }
export extern "jj log" [...args]

@complete complete-jj
@structured [--color always --no-graph -T $jj_evolog_template] { jj-decode evolog }
export extern "jj evolog" [...args]

@complete complete-jj
@structured [--color always --no-graph -T $jj_op_template] { jj-decode op }
export extern "jj op log" [...args]

@complete complete-jj
@structured [--color always --no-graph -T $jj_op_template] { jj-decode op }
export extern "jj operation log" [...args]

@complete complete-jj
@structured [--color always -T $jj_bookmark_template] { jj-decode bookmark }
export extern "jj bookmark list" [...args]

@complete complete-jj
@structured [--color always -T $jj_tag_template] { jj-decode bookmark }
export extern "jj tag list" [...args]

@complete complete-jj
@structured [-T 'json(self) ++ "\n"'] { jj-decode workspace }
export extern "jj workspace list" [...args]

@complete complete-jj
@structured [-T 'json(self) ++ "\n"'] { jj-decode config }
export extern "jj config list" [...args]
