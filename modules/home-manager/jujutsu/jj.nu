def complete-jj [spans: list<string>] {
    with-env {COMPLETE: fish} { ^jj -- ...$spans | complete }
    | get stdout
    | lines
    | parse --regex '^(?<value>[^\t]*)(?:\t(?<description>.*))?$'
}

@complete complete-jj
extern jj [...args]
