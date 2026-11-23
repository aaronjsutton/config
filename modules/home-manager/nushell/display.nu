# Rename columns for display only, as listed in the input's "headers"
# metadata, so the data keeps names that are easy to select.
export def "display headers" []: any -> any {
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

export def "display tag" [format: string]: any -> any {
    metadata set {|m| $m | merge {display: $format} }
}

export def --env "display add" [name: string, spec: record] {
    $env.DISPLAY_FORMATS = $env.DISPLAY_FORMATS? | default {} | upsert $name $spec
}

def apply-format [spec: record, meta: record]: table -> table {
    let input = $in
    let rows = if $spec.table? == null { $input } else { $input | do $spec.table $meta }
    let present = $rows | columns
    let formats = $spec.columns? | default {} | transpose name format | where name in $present
    $rows
    | each {|row|
        $formats | reduce --fold $row {|f acc| $acc | update $f.name ($row | get $f.name | do $f.format $row $meta) }
    }
    | reject --optional ...($spec.hide? | default [])
}

export def main []: any -> any {
    metadata access {|m|
        let out = $in
        let spec = $env.DISPLAY_FORMATS? | default {} | get --optional ($m.display? | default '')
        let shape = $out | describe
        let base = $m | reject --optional span display
        let plain = {|| $out | metadata set {|c| $c | merge $base } }
        let keep = {|c| $base | merge {headers: ($base.headers? | default {} | merge ($spec.headers? | default {}))} }
        if $spec == null {
            do $plain
        } else if ($shape | str starts-with 'table') {
            try { $out | apply-format $spec $base | metadata set $keep } catch { do $plain }
        } else if ($shape | str starts-with 'record') {
            try { [$out] | apply-format $spec $base | first | metadata set $keep } catch { do $plain }
        } else {
            do $plain
        }
    }
}

export alias d = main

export-env {
    $env.DISPLAY_FORMATS = $env.DISPLAY_FORMATS? | default {}
    $env.config.hooks.display_output = {||
        main | display headers | if (term size).columns >= 100 { table -e } else { table }
    }
}
