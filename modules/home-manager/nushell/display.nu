# Rename columns for display only, as listed in the input's "headers"
# metadata, so the data keeps names that are easy to select.
export def display-headers []: any -> any {
    metadata access {|m|
        let out = $in
        let headers = $m.headers? | default {}
        let present = if ($headers | is-empty) or (($out | describe) !~ '^(table|record)') {
            []
        } else {
            $headers | transpose old new | where old in ($out | columns)
        }
        if ($present | is-empty) {
            $out
        } else {
            $out | rename --column ($present | reduce --fold {} {|h acc| $acc | insert $h.old $h.new })
        }
        | metadata set {|c| $c | merge ($m | reject --optional span) }
    }
}

export def display-view []: any -> any {
    metadata access {|m|
        let out = $in
        let view = $env.VIEWS? | default {} | get --optional ($m.view? | default '')
        let shape = $out | describe
        let keep = {|c| $m | reject --optional span view | merge ($c | reject --optional span view) }
        let plain = {|| $out | metadata set {|c| $c | merge ($m | reject --optional span view) } }
        if $view == null {
            do $plain
        } else if ($shape | str starts-with 'table') {
            try { $out | do $view | metadata set $keep } catch { do $plain }
        } else if ($shape | str starts-with 'record') {
            try { [$out] | do $view | first | metadata set $keep } catch { do $plain }
        } else {
            do $plain
        }
    }
}

export-env {
    $env.VIEWS = $env.VIEWS? | default {}
    $env.config.hooks.display_output = {||
        display-view | display-headers | if (term size).columns >= 100 { table -e } else { table }
    }
}
