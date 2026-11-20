use std/assert

def shade [s: string]: nothing -> string {
    [green red yellow cyan light_blue light_gray dark_gray xterm_darkorange3b] | where {|c| ($s | str starts-with (ansi $c)) or ($s | str starts-with (ansi $"($c)_bold")) } | first
}

run-tests {
    "aliases expand in the first word only": {||
        assert equal ([ls] | coder-expand) [list]
        assert equal ([org list] | coder-expand) [organizations list]
        assert equal ([list ls] | coder-expand) [list ls]
        assert equal ([ssh dev] | coder-expand) [ssh dev]
        assert equal ([] | coder-expand) []
    }
    "the longest JSON-capable command is found": {||
        assert equal (coder-json-command [list]) 'list'
        assert equal (coder-json-command [list --all]) 'list'
        assert equal (coder-json-command [stat]) 'stat'
        assert equal (coder-json-command [stat cpu]) 'stat cpu'
        assert equal (coder-json-command [schedule show dev]) 'schedule show'
        assert equal (coder-json-command [templates versions list x]) 'templates versions list'
    }
    "other commands are passed through": {||
        assert equal (coder-json-command [ssh dev]) null
        assert equal (coder-json-command [schedule extend dev 1h]) null
        assert equal (coder-json-command [--help]) null
        assert equal (coder-json-command []) null
    }
    "blank timestamps stay blank": {||
        assert equal ('' | coder-et) null
        assert equal (null | coder-et) null
    }
    "today's times have no weekday": {||
        let now = date now
        let expected = $now | date to-timezone America/New_York | format date '%H:%M ET'
        assert equal ($now | format date '%+' | coder-et) $expected
    }
    "other days show the weekday in Eastern time": {||
        assert equal ('2030-01-02T15:00:00Z' | coder-et) 'Wed 10:00 ET'
    }
    "colour follows the time left": {||
        let at = {|d| (date now) + $d | format date '%+' | coder-et --color }
        assert equal (shade (do $at 10min)) red
        assert equal (shade (do $at 1hr)) yellow
        assert equal (shade (do $at 3hr)) green
    }
    "a single owner is dropped": {||
        let rows = [[workspace]; [me/dev] [me/abc-123]]
        assert equal ($rows | coder-strip-owner | get workspace) [dev abc-123]
    }
    "mixed owners are kept": {||
        let rows = [[workspace]; [me/dev] [you/dev]]
        assert equal ($rows | coder-strip-owner | get workspace) [me/dev you/dev]
    }
    "ticket workspaces are orange, others cyan": {||
        assert equal (shade ('abc-123' | coder-color-workspace)) xterm_darkorange3b
        assert equal (shade ('me/abc-123' | coder-color-workspace)) xterm_darkorange3b
        assert equal (shade ('dev' | coder-color-workspace)) cyan
        assert equal (shade ('abc-123x' | coder-color-workspace)) cyan
        assert equal ('me/dev' | coder-color-workspace | ansi strip) 'me/dev'
    }
    "statuses map to glyphs and colours": {||
        let look = {|status healthy outdated| $status | coder-status $healthy $outdated | [($in | ansi strip) (shade $in)] }
        assert equal (do $look running true false) [● green]
        assert equal (do $look running false false) [◉ yellow]
        assert equal (do $look starting true false) [○ green]
        assert equal (do $look pending true false) [○ yellow]
        assert equal (do $look stopping true false) [○ dark_gray]
        assert equal (do $look stopped true false) [◌ dark_gray]
        assert equal (do $look failed true false) [◉ red]
        assert equal (do $look canceling true false) [○ red]
        assert equal (do $look canceled true false) [◌ red]
        assert equal (do $look deleting true false) [○ red]
        assert equal (do $look deleted true false) [◌ dark_gray]
        assert ('stopped' | coder-status true | str starts-with (ansi dark_gray_bold))
    }
    "outdated workspaces are light blue": {||
        let look = {|status healthy| $status | coder-status $healthy true | [($in | ansi strip) (shade $in)] }
        assert equal (do $look running true) [◐ light_blue]
        assert equal (do $look stopped true) [◌ light_blue]
        assert equal (do $look running false) [◉ yellow]
        assert equal (do $look starting true) [○ green]
        assert equal ('running' | coder-status true) ('running' | coder-status true false)
    }
    "untagged output keeps its headers": {||
        assert equal ([{status: x}] | display-headers | columns) [status]
        assert equal ('text' | display-headers) 'text'
        assert equal ([{a: 1}] | metadata set {|m| $m | merge {headers: {status: state}} } | display-headers | columns) [a]
    }
}
