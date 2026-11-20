# Mirrors the zsh prompt: %B%n%b@%m %1~ %(?.%F{2}❯.%F{1}❯)%f
let host = (sys host | get hostname | split row '.' | first)

$env.PROMPT_COMMAND = {||
    let dir = if $env.PWD == $nu.home-dir {
        '~'
    } else {
        $env.PWD | path basename | if ($in | is-empty) { '/' } else { $in }
    }
    let color = if $env.LAST_EXIT_CODE == 0 { 'green' } else { 'red' }
    $"(ansi attr_bold)($env.USER)(ansi reset)@($host) ($dir) (ansi $color)❯(ansi reset) "
}
$env.PROMPT_COMMAND_RIGHT = {|| '' }
$env.PROMPT_INDICATOR = ''
$env.PROMPT_INDICATOR_VI_INSERT = ''
$env.PROMPT_INDICATOR_VI_NORMAL = ''
$env.PROMPT_MULTILINE_INDICATOR = ''
