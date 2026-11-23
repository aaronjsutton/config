use std/assert
use std/testing *
use ../modules/home-manager/nushell/display.nu *

def --env ten [] {
    display add ten {
        columns: {a: {|| $in * 10 }}
        headers: {a: A}
    }
}

@test
def "untagged output keeps its headers" [] {
    assert equal ([{status: x}] | display headers | columns) [status]
    assert equal ('text' | display headers) 'text'
    assert equal ([{a: 1}] | metadata set {|m| $m | merge {headers: {status: state}} } | display headers | columns) [a]
}

@test
def "ls output keeps its path columns for display" [] {
    let tag = {|m| $m | merge {path_columns: [name]} }
    assert equal ([{name: x, type: file}] | metadata set $tag | display headers | metadata | get path_columns?) [name]
    assert equal ([{name: x, type: file}] | metadata set $tag | metadata set {|m| $m | merge {headers: {type: kind}} } | display headers | metadata | get path_columns?) [name]
    assert equal ([{name: x, type: file}] | metadata set $tag | metadata set {|m| $m | merge {headers: {type: kind}} } | display headers | columns) [name kind]
}

@test
def "display add registers and replaces formats" [] {
    $env.DISPLAY_FORMATS = {}
    display add a {hide: [x]}
    display add b {hide: [y]}
    display add a {hide: [z]}
    assert equal $env.DISPLAY_FORMATS {a: {hide: [z]}, b: {hide: [y]}}
}

@test
def "display tag tags output with its format" [] {
    assert equal ([[a]; [1]] | display tag ten | metadata | get display) ten
}

@test
def "a registered format applies to tagged tables" [] {
    ten
    assert equal ([[a b]; [1 x]] | display tag ten | display | display headers) [[A b]; [10 x]]
}

@test
def "a format applies to a single tagged row" [] {
    ten
    assert equal ([[a b]; [1 x]] | display tag ten | first | display | display headers) {A: 10, b: x}
}

@test
def "column formats see the whole row" [] {
    display add sum {columns: {a: {|r| $r.a + $r.b }}}
    assert equal ([[a b]; [1 2]] | display tag sum | display) [[a b]; [3 2]]
}

@test
def "the table step runs before column formats" [] {
    display add sorted {
        table: {|| sort-by a }
        columns: {a: {|| $in * 10 }}
    }
    assert equal ([[a]; [2] [1]] | display tag sorted | display) [[a]; [10] [20]]
}

@test
def "missing columns are skipped and hidden ones removed" [] {
    display add partial {
        columns: {a: {|| $in * 10 }, gone: {|| error make {msg: never} }}
        hide: [b missing]
    }
    assert equal ([[a b c]; [1 2 3]] | display tag partial | display) [[a c]; [10 3]]
    assert equal ([[c]; [3]] | display tag partial | display) [[c]; [3]]
}

@test
def "the tag is consumed and other metadata kept" [] {
    ten
    let meta = [[a b]; [1 x]] | display tag ten | metadata set {|m| $m | merge {path_columns: [b], headers: {b: B}} } | display | metadata
    assert equal ($meta.display?) null
    assert equal ($meta.path_columns) [b]
    assert equal ($meta.headers) {b: B, a: A}
}

@test
def "untagged, unknown and non-table output pass through" [] {
    ten
    assert equal ([[a]; [1]] | display) [[a]; [1]]
    assert equal ([[a]; [1]] | display tag nope | display) [[a]; [1]]
    assert equal ([[a]; [1]] | display tag ten | get a | display) [1]
}

@test
def "a failing format falls back to the plain table" [] {
    ten
    assert equal ([[a]; [y]] | display tag ten | display) [[a]; [y]]
}

@test
def "d is display" [] {
    ten
    assert equal ([[a b]; [1 x]] | display tag ten | d | display headers) [[A b]; [10 x]]
}
