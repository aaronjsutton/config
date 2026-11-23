use std/assert

let hook = $env.config.hooks.pre_prompt | last
let root = $env.HOME | path join shadowenv-test
let outside = $root | path join outside
let project = $root | path join project
let untrusted = $root | path join untrusted
mkdir $outside ($project | path join .shadowenv.d) ($project | path join sub) ($untrusted | path join .shadowenv.d)
'(env/set "SHADOW_TEST" "on")
(env/prepend-to-pathlist "PATH" "/opt/shadow-test/bin")' | save ($project | path join .shadowenv.d 100-test.lisp)
'(env/set "SHADOW_TEST" "untrusted")' | save ($untrusted | path join .shadowenv.d 100-test.lisp)
do { cd $project; ^shadowenv trust }

let start_path = $env.PATH

let visits = do --env {
    mut seen = []
    for dir in [$outside $project ($project | path join sub) $outside $untrusted] {
        cd $dir
        let before = $env.__shadowenv_data? | default ''
        let error = try { do --env $hook; null } catch {|e| $e.msg }
        $seen = $seen | append {
            dir: ($dir | path relative-to $root)
            var: ($env.SHADOW_TEST? | default null)
            path_type: ($env.PATH | describe)
            path: $env.PATH
            error: $error
            change: (shadowenv-change $before ($env.__shadowenv_data? | default ''))
        }
    }
    $seen
}

run-tests {
    "nothing changes outside a project": {||
        let v = $visits.0
        assert equal $v.var null
        assert equal $v.path $start_path
    }
    "entering a project sets its variables": {||
        assert equal $visits.1.var on
    }
    "PATH stays a list with the project entry first": {||
        assert equal $visits.1.path_type 'list<string>'
        assert equal $visits.1.path.0 /opt/shadow-test/bin
        assert equal ($visits.1.path | skip 1) $start_path
    }
    "subdirectories keep the project environment": {||
        assert equal $visits.2.var on
        assert equal $visits.2.path $visits.1.path
    }
    "leaving restores the environment": {||
        assert equal $visits.3.var null
        assert equal $visits.3.path_type 'list<string>'
        assert equal $visits.3.path $start_path
    }
    "the hook never raises an error": {||
        assert equal ($visits | where error != null | get dir) []
    }
    "entering, leaving and switching are told apart": {||
        let off = '0000000000000000:{}'
        assert equal (shadowenv-change '' 'aaaa:{}') '+'
        assert equal (shadowenv-change $off 'aaaa:{}') '+'
        assert equal (shadowenv-change 'aaaa:{}' $off) '-'
        assert equal (shadowenv-change 'aaaa:{"x":1}' 'bbbb:{}') '+|-'
        assert equal (shadowenv-change 'aaaa:{"x":1}' 'aaaa:{"x":2}') null
        assert equal (shadowenv-change '' $off) null
        assert equal (shadowenv-change '' '') null
    }
    "announcements match the zsh hook's text": {||
        assert equal (shadowenv-announce '+' | ansi strip) '░shadowenv[+]'
        assert equal (shadowenv-announce '-' | ansi strip) '░shadowenv[-]'
        assert equal (shadowenv-announce '+|-' | ansi strip) '░shadowenv[+|-]'
        assert ((shadowenv-announce '+') | str contains $"(ansi green)+")
        assert ((shadowenv-announce '-') | str contains $"(ansi red)-")
    }
    "each visit announces the right change": {||
        assert equal ($visits | get change) [null '+' null '-' null]
    }
    "untrusted projects are ignored": {||
        assert equal $visits.4.var null
        assert equal $visits.4.path $start_path
    }
}
