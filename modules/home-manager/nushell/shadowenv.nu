$env.config.hooks.pre_prompt = (
    $env.config.hooks.pre_prompt? | default [] | append {||
        let out = ^shadowenv hook --json --shellpid $nu.pid | str trim
        if ($out | is-empty) { return }
        let parsed = $out | from json
        let vars = $parsed.exported | merge $parsed.unexported | transpose name value
        let unset = $vars | where value == null | get name
        let set = $vars | where value != null
        if ($unset | is-not-empty) { hide-env --ignore-errors ...$unset }
        if ($set | is-not-empty) { load-env ($set | transpose -rd) }
    }
)
