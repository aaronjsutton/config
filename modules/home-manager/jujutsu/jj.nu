def complete-jj [place: record] {
    with-env {COMPLETE: fish} { ^jj -- ...$place.command | complete }
    | get stdout
    | lines
    | parse --regex '^(?<value>[^\t]*)(?:\t(?<description>.*))?$'
}

@complete complete-jj
extern jj [...args]
