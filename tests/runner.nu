def run-tests [tests: record] {
    let results = $tests | items {|name, body|
        try {
            do $body
            print $"ok    ($name)"
            true
        } catch {|e|
            print $"FAIL  ($name)"
            print ($e.rendered? | default $e.msg)
            false
        }
    }
    let failed = $results | where not $it | length
    print $"($results | length) tests, ($failed) failed"
    if $failed > 0 { exit 1 }
}
