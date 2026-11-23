use @completion@ [complete-probe]

def complete-jj [place: record] {
    let typed = $place.command | first | split row ' ' | append ($place.command | skip 1)
    let current = $typed | last
    let words = $typed | drop 1 | append (complete-probe $current)
    with-env {COMPLETE: fish} { ^jj -- ...$words | complete }
    | get stdout
    | lines
    | parse --regex '^(?<value>[^\t]*)(?:\t(?<description>.*))?$'
}

export def jj-decode []: string -> table {
    lines | each { from json }
}

@complete complete-jj
export extern main [...args]

@complete complete-jj
@structured [--no-graph -T 'json(self) ++ "\n"'] { jj-decode }
export extern "jj log" [...args]

@complete complete-jj
@structured [--no-graph -T 'json(self) ++ "\n"'] { jj-decode }
export extern "jj evolog" [...args]

@complete complete-jj
@structured [--no-graph -T 'json(self) ++ "\n"'] { jj-decode }
export extern "jj op log" [...args]

@complete complete-jj
@structured [--no-graph -T 'json(self) ++ "\n"'] { jj-decode }
export extern "jj operation log" [...args]

@complete complete-jj
@structured [-T 'json(self) ++ "\n"'] { jj-decode }
export extern "jj bookmark list" [...args]

@complete complete-jj
@structured [-T 'json(self) ++ "\n"'] { jj-decode }
export extern "jj tag list" [...args]

@complete complete-jj
@structured [-T 'json(self) ++ "\n"'] { jj-decode }
export extern "jj workspace list" [...args]

@complete complete-jj
@structured [-T 'json(self) ++ "\n"'] { jj-decode }
export extern "jj config list" [...args]
