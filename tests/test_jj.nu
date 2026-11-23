use std/assert
use std/testing *
use ../modules/home-manager/jujutsu/jj.nu *
use ../modules/home-manager/nushell/display.nu [main "display headers"]

def commit [change: string, description: string]: nothing -> record {
    {
        commit_id: $"($change)-commit-id"
        parents: [parent-commit-id]
        change_id: $"($change)-change-id"
        description: $description
        author: {name: Me, email: me@example.com, timestamp: '2030-01-02T15:00:00-05:00'}
        committer: {name: Me, email: me@example.com, timestamp: '2030-01-02T16:00:00-05:00'}
    }
}

def operation [id: string]: nothing -> record {
    {
        id: $"($id)-operation-id"
        parents: [parent-operation-id]
        time: {start: '2030-01-02T15:00:00-05:00', end: '2030-01-02T15:00:01-05:00'}
        description: 'snapshot working copy'
        hostname: host
        username: me
        is_snapshot: true
        workspace_name: default
        attributes: {}
    }
}

def json-lines []: list -> string {
    each { to json --raw } | str join "\n"
}

@test
def "commits decode with real timestamps" [] {
    let rows = [(commit abc 'one')] | json-lines | jj-decode commit
    assert equal ($rows.0.author.timestamp) 2030-01-02T15:00:00-05:00
    assert equal ($rows.0.committer.timestamp | describe) datetime
    assert equal ([(commit abc 'one')] | json-lines | jj-decode commit | metadata | get display) jj-commit
}

@test
def "evolog entries flatten into commits with their operation" [] {
    let rows = [{commit: (commit abc 'one'), operation: (operation op)}] | json-lines | jj-decode evolog
    assert equal ($rows.0.change_id) abc-change-id
    assert equal ($rows.0.operation.id) op-operation-id
    assert equal ($rows.0.operation.time.start | describe) datetime
    assert equal ([{commit: (commit abc 'one'), operation: (operation op)}] | json-lines | jj-decode evolog | metadata | get display) jj-commit
}

@test
def "operations decode with real times" [] {
    let rows = [(operation op)] | json-lines | jj-decode op
    assert equal ($rows.0.time.end) 2030-01-02T15:00:01-05:00
    assert equal ([(operation op)] | json-lines | jj-decode op | metadata | get display) jj-op
}

@test
def "local and remote bookmarks share columns" [] {
    let rows = [
        {name: main, target: [a]}
        {name: main, remote: origin, target: [a], tracking_target: [a]}
    ] | json-lines | jj-decode bookmark
    assert equal $rows [[name target remote tracking_target]; [main [a] null []] [main [a] origin [a]]]
}

@test
def "workspace targets decode as commits" [] {
    let rows = [{name: default, target: (commit abc 'one')}] | json-lines | jj-decode workspace
    assert equal ($rows.0.target.author.timestamp | describe) datetime
}

@test
def "empty output decodes to no rows" [] {
    assert equal ('' | jj-decode commit) []
}

@test
def "commits display with short ids and subjects" [] {
    use ../modules/home-manager/jujutsu/jj.nu []
    let shown = {|| [(commit abcdefghij "subject\n\nbody") (commit klmnopqrst '')] | json-lines | jj-decode commit | display }
    assert equal (do $shown | display headers | columns) [change commit description author committed]
    assert equal (do $shown | get change_id | ansi strip) [abcdefgh klmnopqr]
    assert equal (do $shown | get description | ansi strip) [subject '(no description set)']
    assert equal (do $shown | get author) [me@example.com me@example.com]
    assert equal (do $shown | get 0.committer) 2030-01-02T16:00:00-05:00
}

@test
def "operations display with short ids and start times" [] {
    use ../modules/home-manager/jujutsu/jj.nu []
    let shown = {|| [(operation abcdefghijklmnop)] | json-lines | jj-decode op | display }
    assert equal (do $shown | display headers | columns) [id started description]
    assert equal (do $shown | get 0.id | ansi strip) abcdefghijkl
}

@test
def "bookmarks display with short targets" [] {
    use ../modules/home-manager/jujutsu/jj.nu []
    let shown = [
        {name: main, target: ['0123456789abcdef']}
        {name: main, remote: origin, target: ['0123456789abcdef'], tracking_target: ['0123456789abcdef']}
    ] | json-lines | jj-decode bookmark | display
    assert equal ($shown | get target | ansi strip) ['01234567' '01234567']
    assert equal ($shown | get tracking_target | ansi strip) ['' '01234567']
}

@test
def "workspaces display their target commit" [] {
    use ../modules/home-manager/jujutsu/jj.nu []
    let shown = [{name: default, target: (commit abcdefghij "subject")}] | json-lines | jj-decode workspace | display
    assert equal ($shown.0.target | ansi strip) 'abcdefgh subject'
}

def painted [row: record]: nothing -> string {
    [(ansi red)C (ansi red)K (ansi red)D (ansi red)A (ansi red)T ($row | to json --raw)] | str join "\t"
}

@test
def "jj colours go to metadata and the data stays plain" [] {
    let row = commit abcdefghij 'subject'
    let rows = painted $row | jj-decode commit
    assert equal ($rows.0.change_id) abcdefghij-change-id
    assert not ($rows | to json | str contains (ansi escape))
    let colors = painted $row | jj-decode commit | metadata | get jj_colors
    assert equal ($colors | get abcdefghij-commit-id) {change_id: $"(ansi red)C", commit_id: $"(ansi red)K", description: $"(ansi red)D", author: $"(ansi red)A", committer: $"(ansi red)T"}
}

@test
def "commits display in jj colours" [] {
    use ../modules/home-manager/jujutsu/jj.nu []
    let shown = painted (commit abcdefghij 'subject') | jj-decode commit | display
    assert equal ($shown.0 | select change_id commit_id description author committer | values) [$"(ansi red)C" $"(ansi red)K" $"(ansi red)D" $"(ansi red)A" $"(ansi red)T"]
}

@test
def "commits without their id fall back to our own colours" [] {
    use ../modules/home-manager/jujutsu/jj.nu []
    let shown = painted (commit abcdefghij 'subject') | jj-decode commit | select change_id description | display
    assert equal ($shown.0.change_id | ansi strip) abcdefgh
    assert equal ($shown.0.description) subject
}

@test
def "operations display in jj colours" [] {
    use ../modules/home-manager/jujutsu/jj.nu []
    let line = [(ansi red)I (ansi red)T (ansi red)D ((operation abcdefghijklmnop) | to json --raw)] | str join "\t"
    let shown = $line | jj-decode op | display
    assert equal ($shown.0 | select id time description | values) [$"(ansi red)I" $"(ansi red)T" $"(ansi red)D"]
}

@test
def "local and remote bookmarks display in jj colours" [] {
    use ../modules/home-manager/jujutsu/jj.nu []
    let lines = [
        ([(ansi red)L '' (ansi red)LT ({name: main, target: ['0123456789abcdef']} | to json --raw)] | str join "\t")
        ([(ansi red)R (ansi red)@origin (ansi red)RT ({name: main, remote: origin, target: ['0123456789abcdef'], tracking_target: ['0123456789abcdef']} | to json --raw)] | str join "\t")
    ] | str join "\n"
    let shown = $lines | jj-decode bookmark | display
    assert equal ($shown | get name) [$"(ansi red)L" $"(ansi red)R"]
    assert equal ($shown | get remote) ['' $"(ansi red)@origin"]
    assert equal ($shown | get target) [$"(ansi red)LT" $"(ansi red)RT"]
    assert equal ($shown | get tracking_target | ansi strip) ['' '01234567']
}
