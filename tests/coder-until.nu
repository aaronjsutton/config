use std/assert

def ny [t: datetime]: nothing -> string {
    $t | date to-timezone America/New_York | format date '%Y-%m-%dT%H:%M:%S%:z'
}

let today = date now | date to-timezone America/New_York | format date '%F'

run-tests {
    "times are recognised": {||
        for t in ['9:00' '09:00' '17:30' '17:30:15' '2026-11-21T09:00:00' '2026-11-21T09:00:00-05:00'] {
            assert (looks-like-time $t) $t
        }
    }
    "workspace names are not times": {||
        for t in ['abc-123' 'my-workspace' '1730' 'noon'] {
            assert not (looks-like-time $t) $t
        }
    }
    "times with an offset are taken as is": {||
        assert equal (resolve '2026-11-21T09:00:00-08:00' America/New_York) ('2026-11-21T09:00:00-08:00' | into datetime)
        assert equal (resolve '2026-11-21T14:00:00Z' America/New_York) ('2026-11-21T14:00:00Z' | into datetime)
    }
    "naive datetimes are read in the zone": {||
        assert equal (ny (resolve '2026-11-21T09:00:00' America/New_York)) '2026-11-21T09:00:00-05:00'
        assert equal (ny (resolve '2026-07-01T09:00:00' America/New_York)) '2026-07-01T09:00:00-04:00'
    }
    "times after the spring switch get the new offset": {||
        assert equal (ny (resolve '2026-03-08T01:30:00' America/New_York)) '2026-03-08T01:30:00-05:00'
        assert equal (ny (resolve '2026-03-08T03:30:00' America/New_York)) '2026-03-08T03:30:00-04:00'
        assert equal (ny (resolve '2026-03-08T06:30:00' America/New_York)) '2026-03-08T06:30:00-04:00'
        assert equal (ny (resolve '2026-03-08T12:00:00' America/New_York)) '2026-03-08T12:00:00-04:00'
    }
    "times after the autumn switch get the new offset": {||
        assert equal (ny (resolve '2026-11-01T00:30:00' America/New_York)) '2026-11-01T00:30:00-04:00'
        assert equal (ny (resolve '2026-11-01T03:00:00' America/New_York)) '2026-11-01T03:00:00-05:00'
        assert equal (ny (resolve '2026-11-01T05:00:00' America/New_York)) '2026-11-01T05:00:00-05:00'
    }
    "clock times are today in the zone": {||
        assert equal (resolve '17:30' America/New_York | date to-timezone America/New_York | format date '%F %T') $"($today) 17:30:00"
        assert equal (resolve '9:05' America/New_York | date to-timezone America/New_York | format date '%F %T') $"($today) 09:05:00"
        assert equal (resolve '08:00:30' America/New_York | date to-timezone America/New_York | format date '%F %T') $"($today) 08:00:30"
    }
    "unset deadlines parse to null": {||
        assert equal ('' | parse-deadline) null
        assert equal (null | parse-deadline) null
        assert equal ('0001-01-01T00:00:00Z' | parse-deadline) null
    }
    "deadlines parse to datetimes": {||
        assert equal ('2026-11-21T22:30:00Z' | parse-deadline) ('2026-11-21T22:30:00Z' | into datetime)
    }
    "today is shown without a weekday": {||
        let t = $"($today)T17:30:00" | resolve $in America/New_York
        assert equal (fmt $t America/New_York) '17:30 ET'
    }
    "other days show the weekday": {||
        let t = (date now) + 3day
        let expected = $t | date to-timezone America/New_York | format date '%a %H:%M ET'
        assert equal (fmt $t America/New_York) $expected
    }
    "other zones show their offset": {||
        let t = '2026-07-01T20:00:00Z' | into datetime
        assert equal (fmt $t UTC) 'Wed 20:00 +00:00'
        assert equal (fmt $t America/Los_Angeles) 'Wed 13:00 -07:00'
    }
    "missing times show a dash": {||
        assert equal (null | fmt-or-dash America/New_York) '—'
    }
    "the last non-empty output line is the error": {||
        assert equal (last-line {stdout: '', stderr: "first\nsecond\n\n"}) 'second'
        assert equal (last-line {stdout: "out\n", stderr: ''}) 'out'
        assert equal (last-line {stdout: '', stderr: ''}) 'unknown error'
    }
    "times in the past are refused": {||
        let e = try { coder-until '2000-01-01T09:00:00Z'; null } catch {|e| $e.msg }
        assert ($e | str contains 'has already passed') $e
    }
    "times under 30 minutes away are refused": {||
        let soon = (date now) + 10min | format date '%Y-%m-%dT%H:%M:%S%:z'
        let e = try { coder-until $soon; null } catch {|e| $e.msg }
        assert ($e | str contains 'minutes away') $e
    }
}
