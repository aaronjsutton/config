export def complete-probe [token: string]: nothing -> string {
    if ($token | str starts-with '-') {
        '-'
    } else if ($token | str contains '/') {
        $token | str replace --regex '[^/]*$' ''
    } else {
        ''
    }
}
