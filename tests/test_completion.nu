use std/assert
use std/testing *
use ../modules/home-manager/nushell/completion.nu *

@test
def "flags, paths and words probe differently" [] {
    assert equal (complete-probe '--al') '-'
    assert equal (complete-probe 'src/mo') 'src/'
    assert equal (complete-probe 'li') ''
}

@test
def "subcommand names split into words" [] {
    assert equal (complete-words {command: ['jj log' '-r' '@']}) [jj log -r @]
    assert equal (complete-words {command: [jj sq]}) [jj sq]
}
