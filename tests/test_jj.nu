use std/assert
use std/testing *
use ../modules/home-manager/jujutsu/jj.nu *

@test
def "each JSON line decodes to a row" [] {
    let out = '{"name":"main","target":["abc"]}
{"name":"dev","target":["def"]}
' | jj-decode
    assert equal $out [[name target]; [main [abc]] [dev [def]]]
}

@test
def "empty output decodes to no rows" [] {
    assert equal ('' | jj-decode) []
}
