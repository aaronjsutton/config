use std/assert

def shade [s: string]: nothing -> string {
    [green red yellow cyan light_gray xterm_darkorange3b] | where {|c| $s | str starts-with (ansi $c) } | first
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
    "statuses map to colours": {||
        assert equal (shade ('running' | coder-status true)) green
        assert equal (shade ('running' | coder-status false)) red
        assert equal (shade ('stopped' | coder-status true)) light_gray
        assert equal (shade ('deleted' | coder-status true)) light_gray
        assert equal (shade ('failed' | coder-status true)) red
        assert equal (shade ('starting' | coder-status true)) yellow
    }
}
