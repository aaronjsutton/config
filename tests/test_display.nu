use std/assert
use std/testing *
use ../modules/home-manager/nushell/display.nu *

def tagged [view: string]: table -> table {
    metadata set {|m| $m | merge {view: $view} }
}

def times-ten []: table -> table {
    update a { $in * 10 } | metadata set {|m| $m | merge {headers: {a: A}} }
}

@test
def "untagged output keeps its headers" [] {
    assert equal ([{status: x}] | display-headers | columns) [status]
    assert equal ('text' | display-headers) 'text'
    assert equal ([{a: 1}] | metadata set {|m| $m | merge {headers: {status: state}} } | display-headers | columns) [a]
}

@test
def "ls output keeps its path columns for display" [] {
    let tag = {|m| $m | merge {path_columns: [name]} }
    assert equal ([{name: x, type: file}] | metadata set $tag | display-headers | metadata | get path_columns?) [name]
    assert equal ([{name: x, type: file}] | metadata set $tag | metadata set {|m| $m | merge {headers: {type: kind}} } | display-headers | metadata | get path_columns?) [name]
    assert equal ([{name: x, type: file}] | metadata set $tag | metadata set {|m| $m | merge {headers: {type: kind}} } | display-headers | columns) [name kind]
}

@test
def "a registered view formats tagged tables" [] {
    $env.VIEWS = {ten: {|| times-ten }}
    assert equal ([[a b]; [1 x]] | tagged ten | display-view | display-headers) [[A b]; [10 x]]
}

@test
def "a view applies to a single tagged row" [] {
    $env.VIEWS = {ten: {|| times-ten }}
    assert equal ([[a b]; [1 x]] | tagged ten | first | display-view | display-headers) {A: 10, b: x}
}

@test
def "the view tag is consumed and other metadata kept" [] {
    $env.VIEWS = {ten: {|| times-ten }}
    let meta = [[a b]; [1 x]] | tagged ten | metadata set {|m| $m | merge {path_columns: [b]} } | display-view | metadata
    assert equal ($meta.view?) null
    assert equal ($meta.path_columns) [b]
    assert equal ($meta.headers) {a: A}
}

@test
def "untagged, unknown and non-table output pass through" [] {
    $env.VIEWS = {ten: {|| times-ten }}
    assert equal ([[a]; [1]] | display-view) [[a]; [1]]
    assert equal ([[a]; [1]] | tagged nope | display-view) [[a]; [1]]
    assert equal ([[a]; [1]] | tagged ten | get a | display-view) [1]
}

@test
def "a failing view falls back to the plain table" [] {
    $env.VIEWS = {ten: {|| times-ten }}
    assert equal ([[a]; [y]] | tagged ten | display-view) [[a]; [y]]
}
