use std/assert
use std/testing *
use ../modules/home-manager/shadowenv/shadowenv.nu *
export-env { use ../modules/home-manager/shadowenv/shadowenv.nu }

@before-all
def visit-projects [] {
    let hook = $env.config.hooks.pre_prompt | last
    let root = $env.HOME | path join shadowenv-test
    let outside = $root | path join outside
    let project = $root | path join project
    let untrusted = $root | path join untrusted
    mkdir $outside ($project | path join .shadowenv.d) ($project | path join sub) ($untrusted | path join .shadowenv.d)
    '(env/set "SHADOW_TEST" "on")
(env/prepend-to-pathlist "PATH" "/opt/shadow-test/bin")' | save -f ($project | path join .shadowenv.d 100-test.lisp)
    '(env/set "SHADOW_TEST" "untrusted")' | save -f ($untrusted | path join .shadowenv.d 100-test.lisp)
    do { cd $project; ^shadowenv trust }

    let start_path = $env.PATH
    mut visits = []
    for dir in [$outside $project ($project | path join sub) $outside $untrusted] {
        cd $dir
        let before = $env.__shadowenv_data? | default ''
        let error = try { do --env $hook; null } catch {|e| $e.msg }
        $visits = $visits | append {
            dir: ($dir | path relative-to $root)
            var: ($env.SHADOW_TEST? | default null)
            path_type: ($env.PATH | describe)
            path: $env.PATH
            error: $error
            change: (shadowenv-change $before ($env.__shadowenv_data? | default ''))
        }
    }
    {start_path: $start_path, visits: $visits}
}

@test
def "nothing changes outside a project" [] {
    let v = $in.visits.0
    assert equal $v.var null
    assert equal $v.path $in.start_path
}

@test
def "entering a project sets its variables" [] {
    assert equal $in.visits.1.var on
}

@test
def "PATH stays a list with the project entry first" [] {
    let v = $in.visits.1
    assert equal $v.path_type 'list<string>'
    assert equal $v.path.0 /opt/shadow-test/bin
    assert equal ($v.path | skip 1) $in.start_path
}

@test
def "subdirectories keep the project environment" [] {
    assert equal $in.visits.2.var on
    assert equal $in.visits.2.path $in.visits.1.path
}

@test
def "leaving restores the environment" [] {
    let v = $in.visits.3
    assert equal $v.var null
    assert equal $v.path_type 'list<string>'
    assert equal $v.path $in.start_path
}

@test
def "the hook never raises an error" [] {
    assert equal ($in.visits | where error != null | get dir) []
}

@test
def "entering, leaving and switching are told apart" [] {
    let off = '0000000000000000:{}'
    assert equal (shadowenv-change '' 'aaaa:{}') '+'
    assert equal (shadowenv-change $off 'aaaa:{}') '+'
    assert equal (shadowenv-change 'aaaa:{}' $off) '-'
    assert equal (shadowenv-change 'aaaa:{"x":1}' 'bbbb:{}') '+|-'
    assert equal (shadowenv-change 'aaaa:{"x":1}' 'aaaa:{"x":2}') null
    assert equal (shadowenv-change '' $off) null
    assert equal (shadowenv-change '' '') null
}

@test
def "announcements show the change marks" [] {
    assert equal (shadowenv-announce '+' | ansi strip) 'shadowenv[+]'
    assert equal (shadowenv-announce '-' | ansi strip) 'shadowenv[-]'
    assert equal (shadowenv-announce '+|-' | ansi strip) 'shadowenv[+|-]'
    assert ((shadowenv-announce '+') | str contains $"(ansi green)+")
    assert ((shadowenv-announce '-') | str contains $"(ansi red)-")
}

@test
def "each visit announces the right change" [] {
    assert equal ($in.visits | get change) [null '+' null '-' null]
}

@test
def "untrusted projects are ignored" [] {
    assert equal $in.visits.4.var null
    assert equal $in.visits.4.path $in.start_path
}
