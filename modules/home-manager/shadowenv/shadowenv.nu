export def shadowenv-change [before: string, after: string]: nothing -> any {
    let was = shadowenv-active $before
    let now = shadowenv-active $after
    let hash = {|d| $d | split row ':' | first }
    if $was and $now {
        if (do $hash $before) != (do $hash $after) { '+|-' }
    } else if $now {
        '+'
    } else if $was {
        '-'
    }
}

export def shadowenv-announce [change: string]: nothing -> string {
    let marks = $change | split chars | each {|c|
        match $c { '+' => $"(ansi green)+(ansi reset)", '-' => $"(ansi red)-(ansi reset)", _ => $c }
    }
    $"(ansi light_gray)shadowenv[(ansi reset)($marks | str join)(ansi light_gray)](ansi reset)"
}

export-env {
    $env.config.hooks.pre_prompt = $env.config.hooks.pre_prompt? | default []
    $env.config.hooks.pre_prompt ++= [{||
        let before = $env.__shadowenv_data? | default ''
        let result = ^@shadowenv@ hook --json --shellpid $nu.pid | complete
        if $result.exit_code != 0 { return }
        let out = $result.stdout | str trim
        if ($out | is-empty) { return }
        let parsed = $out | from json
        let vars = $parsed.exported | merge $parsed.unexported | transpose name value
        let unset = $vars | where value == null | get name
        let set = $vars | where value != null | each {|v|
            if $v.name == PATH { $v | update value { split row (char esep) } } else { $v }
        }
        if ($unset | is-not-empty) { hide-env --ignore-errors ...$unset }
        if ($set | is-not-empty) { load-env ($set | transpose -rd) }
        let change = shadowenv-change $before ($env.__shadowenv_data? | default '')
        if $change != null and ($env.SHADOWENV_SILENT? | is-empty) { print --stderr (shadowenv-announce $change) }
    }]
}

def shadowenv-active [data: string]: nothing -> bool {
    ($data | is-not-empty) and not ($data | str starts-with '0000000000000000')
}
