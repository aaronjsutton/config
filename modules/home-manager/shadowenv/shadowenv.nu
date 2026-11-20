$env.config.hooks.pre_prompt = $env.config.hooks.pre_prompt? | default []
$env.config.hooks.pre_prompt ++= [{||
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
}]
