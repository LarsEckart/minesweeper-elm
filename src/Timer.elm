module Timer exposing (Timer, formatTime, getSeconds, init, start, stop, tick)

import Time


type Timer
    = Stopped Int
    | Running Int


init : Timer
init =
    Stopped 0


start : Timer
start =
    Running 0


stop : Timer -> Timer
stop timer =
    case timer of
        Stopped elapsed ->
            Stopped elapsed

        Running seconds ->
            Stopped seconds


tick : Timer -> Timer
tick timer =
    case timer of
        Stopped elapsed ->
            Stopped elapsed

        Running seconds ->
            Running (seconds + 1)


getSeconds : Timer -> Int
getSeconds timer =
    case timer of
        Stopped elapsed ->
            elapsed

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
