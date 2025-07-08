module LeaderBoard exposing
    ( BestTime
    , Difficulty(..)
    , LeaderBoard
    , clearAll
    , decode
    , encode
    , getAllBestTimes
    , getBestTime
    , init
    , updateBestTime
    )

import Json.Decode as Decode
import Json.Encode as Encode


type Difficulty
    = Beginner
    | Intermediate
    | Expert


type alias BestTime =
    { time : Int
    , difficulty : Difficulty
    }


type alias LeaderBoard =
    { beginner : Maybe Int
    , intermediate : Maybe Int
    , expert : Maybe Int
    }


init : LeaderBoard
init =
    { beginner = Nothing
    , intermediate = Nothing
    , expert = Nothing
    }


encode : LeaderBoard -> Encode.Value
encode leaderBoard =
    Encode.object
        [ ( "beginner", encodeMaybeInt leaderBoard.beginner )
        , ( "intermediate", encodeMaybeInt leaderBoard.intermediate )
        , ( "expert", encodeMaybeInt leaderBoard.expert )
        ]


encodeMaybeInt : Maybe Int -> Encode.Value
encodeMaybeInt maybeInt =
    case maybeInt of
        Just time ->
            Encode.int time

        Nothing ->
            Encode.null


decode : Decode.Decoder LeaderBoard
decode =
    Decode.map3 LeaderBoard
        (Decode.field "beginner" (Decode.nullable Decode.int))
        (Decode.field "intermediate" (Decode.nullable Decode.int))
        (Decode.field "expert" (Decode.nullable Decode.int))


updateBestTime : Difficulty -> Int -> LeaderBoard -> LeaderBoard
updateBestTime difficulty time leaderBoard =
    let
        updateIfBetter currentBest newTime =
            case currentBest of
                Nothing ->
                    Just newTime

                Just existing ->
                    if newTime < existing then
                        Just newTime

                    else
                        Just existing
    in
    case difficulty of
        Beginner ->
            { leaderBoard | beginner = updateIfBetter leaderBoard.beginner time }

        Intermediate ->
            { leaderBoard | intermediate = updateIfBetter leaderBoard.intermediate time }

        Expert ->
            { leaderBoard | expert = updateIfBetter leaderBoard.expert time }


getBestTime : Difficulty -> LeaderBoard -> Maybe Int
getBestTime difficulty leaderBoard =
    case difficulty of
        Beginner ->
            leaderBoard.beginner

        Intermediate ->
            leaderBoard.intermediate

        Expert ->
            leaderBoard.expert


getAllBestTimes : LeaderBoard -> List BestTime
getAllBestTimes leaderBoard =
    let
        maybeToList difficulty maybeTime =
            case maybeTime of
                Just time ->
                    [ { time = time, difficulty = difficulty } ]

                Nothing ->
                    []
    in
    []
        |> (++) (maybeToList Beginner leaderBoard.beginner)
        |> (++) (maybeToList Intermediate leaderBoard.intermediate)
        |> (++) (maybeToList Expert leaderBoard.expert)


clearAll : LeaderBoard
clearAll =
    init
