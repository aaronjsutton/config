use std/assert
use std/testing *
use ../modules/home-manager/coder/coder.nu *

def shade [s: string]: nothing -> string {
    [green red yellow cyan light_blue light_gray dark_gray xterm_darkorange3b] | where {|c| ($s | str starts-with (ansi $c)) or ($s | str starts-with (ansi $"($c)_bold")) } | first
}

@test
def "aliases expand in the first word only" [] {
    assert equal ([ls] | coder-expand) [list]
    assert equal ([org list] | coder-expand) [organizations list]
    assert equal ([list ls] | coder-expand) [list ls]
    assert equal ([ssh dev] | coder-expand) [ssh dev]
    assert equal ([] | coder-expand) []
}

@test
def "blank timestamps stay blank" [] {
    assert equal ('' | coder-et) null
    assert equal (null | coder-et) null
}

@test
def "times today have no weekday" [] {
    let now = date now
    let expected = $now | date to-timezone America/New_York | format date '%H:%M ET'
    assert equal ($now | format date '%+' | coder-et) $expected
}

@test
def "other days show the weekday in Eastern time" [] {
    assert equal ('2030-01-02T15:00:00Z' | coder-et) 'Wed 10:00 ET'
}

@test
def "colour follows the time left" [] {
    let at = {|d| (date now) + $d | format date '%+' | coder-et --color }
    assert equal (shade (do $at 10min)) red
    assert equal (shade (do $at 1hr)) yellow
    assert equal (shade (do $at 3hr)) green
}

@test
def "a single owner is dropped" [] {
    let rows = [[workspace]; [me/dev] [me/abc-123]]
    assert equal ($rows | coder-strip-owner | get workspace) [dev abc-123]
}

@test
def "mixed owners are kept" [] {
    let rows = [[workspace]; [me/dev] [you/dev]]
    assert equal ($rows | coder-strip-owner | get workspace) [me/dev you/dev]
}

@test
def "ticket workspaces are orange, others cyan" [] {
    assert equal (shade ('abc-123' | coder-color-workspace)) xterm_darkorange3b
    assert equal (shade ('me/abc-123' | coder-color-workspace)) xterm_darkorange3b
    assert equal (shade ('dev' | coder-color-workspace)) cyan
    assert equal (shade ('abc-123x' | coder-color-workspace)) cyan
    assert equal ('me/dev' | coder-color-workspace | ansi strip) 'me/dev'
}

@test
def "statuses map to glyphs and colours" [] {
    let look = {|status outdated| $status | coder-status $outdated | [($in | ansi strip) (shade $in)] }
    assert equal (do $look running false) [● green]
    assert equal (do $look unhealthy false) [◉ yellow]
    assert equal (do $look starting false) [○ green]
    assert equal (do $look pending false) [○ yellow]
    assert equal (do $look stopping false) [○ dark_gray]
    assert equal (do $look stopped false) [◌ dark_gray]
    assert equal (do $look failed false) [◉ red]
    assert equal (do $look canceling false) [○ red]
    assert equal (do $look canceled false) [◌ red]
    assert equal (do $look deleting false) [○ red]
    assert equal (do $look deleted false) [◌ dark_gray]
    assert ('stopped' | coder-status | str starts-with (ansi dark_gray_bold))
}

@test
def "outdated workspaces are light blue" [] {
    let look = {|status| $status | coder-status true | [($in | ansi strip) (shade $in)] }
    assert equal (do $look running) [◐ light_blue]
    assert equal (do $look stopped) [◌ light_blue]
    assert equal (do $look unhealthy) [◉ yellow]
    assert equal (do $look starting) [○ green]
    assert equal ('running' | coder-status) ('running' | coder-status false)
}

def workspace [name: string, status: string, --healthy = true, --deadline = '']: nothing -> record {
    {
        name: $name
        owner_name: me
        outdated: false
        last_used_at: '2030-01-02T15:00:00Z'
        health: {healthy: $healthy}
        latest_build: {status: $status, deadline: $deadline}
    }
}

@test
def "list decodes to plain rows" [] {
    let rows = [
        (workspace dev running --deadline '2030-01-02T22:00:00Z')
        (workspace abc-123 stopped --deadline '2030-01-02T22:00:00Z')
    ] | to json | coder-decode-list
    assert equal ($rows | columns) [status workspace outdated stops_at last_used]
    assert equal ($rows.workspace) [me/abc-123 me/dev]
    assert equal ($rows.stops_at) [null 2030-01-02T22:00:00Z]
    assert equal ($rows.last_used.0) 2030-01-02T15:00:00Z
}

@test
def "an unhealthy running workspace decodes as unhealthy" [] {
    let rows = [
        (workspace a running --healthy=false)
        (workspace b stopped --healthy=false)
    ] | to json | coder-decode-list
    assert equal ($rows.status) [unhealthy stopped]
}

@test
def "zero deadlines decode to null" [] {
    let rows = [(workspace dev running --deadline '0001-01-01T00:00:00Z')] | to json | coder-decode-list
    assert equal ($rows.0.stops_at) null
}

@test
def "schedule decodes stop times" [] {
    let rows = [
        {workspace: me/b, stops_next: '2030-01-02T22:00:00Z', extra: 1}
        {workspace: me/a, stops_next: ''}
    ] | to json | coder-decode-schedule
    assert equal $rows [[workspace stops_next]; [me/a null] [me/b 2030-01-02T22:00:00Z]]
}

@test
def "view shows the status as the power icon" [] {
    let icon = char --unicode '23fb'
    let view = [(workspace dev stopped)] | to json | coder-decode-list | coder view
    let shown = {|| [(workspace dev stopped)] | to json | coder-decode-list | coder view | display-headers }
    assert equal ($view | columns) [status workspace stops_at last_used]
    assert equal (do $shown | columns) [$icon workspace stops_at last_used]
    assert equal ($view.0.status | ansi strip) ◌
    assert equal ($view.0.workspace | ansi strip) dev
}

@test
def "view formats schedule stop times" [] {
    let view = [[workspace stops_next]; [me/dev 2030-01-02T15:00:00Z]] | coder view
    assert equal ($view.0.stops_next | ansi strip) 'Wed 10:00 ET'
    assert equal ($view | display-headers | columns) [workspace stops_next]
}

@test
def "untagged output keeps its headers" [] {
    assert equal ([{status: x}] | display-headers | columns) [status]
    assert equal ('text' | display-headers) 'text'
    assert equal ([{a: 1}] | metadata set {|m| $m | merge {headers: {status: state}} } | display-headers | columns) [a]
}

@test
def "ls output keeps its path columns for display" [] {
    let tag = {|m| $m | merge {path_columns: [name]} }
    assert equal ([{name: x, type: file}] | metadata set $tag | display-headers | metadata | get path_columns?) [name]
    assert equal ([{name: x, type: file}] | metadata set $tag | metadata set {|m| $m | merge {headers: {type: kind}} } | display-headers | metadata | get path_columns?) [name]
    assert equal ([{name: x, type: file}] | metadata set $tag | metadata set {|m| $m | merge {headers: {type: kind}} } | display-headers | columns) [name kind]
}
