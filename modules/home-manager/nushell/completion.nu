export def complete-probe [token: string]: nothing -> string {
    if ($token | str starts-with '-') {
        '-'
    } else if ($token | str contains '/') {
        $token | str replace --regex '[^/]*$' ''
    } else {
        ''
    }
}

export def complete-words [place: record]: nothing -> list<string> {
    $place.command | first | split row ' ' | append ($place.command | skip 1)
}
