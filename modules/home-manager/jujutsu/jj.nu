use @completion@ [complete-probe]

def complete-jj [place: record] {
    let current = $place.command | last
    let words = $place.command | drop 1 | append (complete-probe $current)
    with-env {COMPLETE: fish} { ^jj -- ...$words | complete }
    | get stdout
    | lines
    | parse --regex '^(?<value>[^\t]*)(?:\t(?<description>.*))?$'
}

@complete complete-jj
export extern main [...args]
