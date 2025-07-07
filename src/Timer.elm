module Timer exposing (Timer, formatTime, getSeconds, init, start, stop, tick)

import Time


type Timer
    = Stopped
    | Running Int


init : Timer
init =
    Stopped


start : Timer
start =
    Running 0


stop : Timer -> Timer
stop timer =
    case timer of
        Stopped ->
            Stopped

        Running seconds ->
            Stopped


tick : Timer -> Timer
tick timer =
    case timer of
        Stopped ->
            Stopped

        Running seconds ->
            Running (seconds + 1)


getSeconds : Timer -> Int
getSeconds timer =
    case timer of
        Stopped ->
            0

        Running seconds ->
            seconds


formatTime : Int -> String
formatTime seconds =
    let
        mins =
            seconds // 60

        secs =
            modBy 60 seconds
    in
    if mins > 0 then
        String.fromInt mins ++ ":" ++ String.padLeft 2 '0' (String.fromInt secs)

    else
        String.fromInt secs
