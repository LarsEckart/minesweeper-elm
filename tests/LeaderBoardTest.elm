module LeaderBoardTest exposing (suite)

import Expect
import Json.Decode as Decode
import Json.Encode as Encode
import LeaderBoard exposing (Difficulty(..))
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "LeaderBoard"
        [ describe "init"
            [ test "creates empty leaderboard" <|
                \_ ->
                    let
                        leaderBoard =
                            LeaderBoard.init
                    in
                    Expect.equal leaderBoard
                        { beginner = Nothing
                        , intermediate = Nothing
                        , expert = Nothing
                        }
            ]
        , describe "updateBestTime"
            [ test "sets first time for beginner" <|
                \_ ->
                    let
                        leaderBoard =
                            LeaderBoard.init
                                |> LeaderBoard.updateBestTime Beginner 120
                    in
                    Expect.equal leaderBoard.beginner (Just 120)
            , test "updates time if better" <|
                \_ ->
                    let
                        leaderBoard =
                            LeaderBoard.init
                                |> LeaderBoard.updateBestTime Beginner 120
                                |> LeaderBoard.updateBestTime Beginner 90
                    in
                    Expect.equal leaderBoard.beginner (Just 90)
            , test "keeps existing time if worse" <|
                \_ ->
                    let
                        leaderBoard =
                            LeaderBoard.init
                                |> LeaderBoard.updateBestTime Beginner 90
                                |> LeaderBoard.updateBestTime Beginner 120
                    in
                    Expect.equal leaderBoard.beginner (Just 90)
            , test "handles different difficulties independently" <|
                \_ ->
                    let
                        leaderBoard =
                            LeaderBoard.init
                                |> LeaderBoard.updateBestTime Beginner 90
                                |> LeaderBoard.updateBestTime Intermediate 180
                                |> LeaderBoard.updateBestTime Expert 300
                    in
                    Expect.all
                        [ \lb -> Expect.equal lb.beginner (Just 90)
                        , \lb -> Expect.equal lb.intermediate (Just 180)
                        , \lb -> Expect.equal lb.expert (Just 300)
                        ]
                        leaderBoard
            ]
        , describe "getBestTime"
            [ test "returns Nothing for empty leaderboard" <|
                \_ ->
                    let
                        result =
                            LeaderBoard.getBestTime Beginner LeaderBoard.init
                    in
                    Expect.equal result Nothing
            , test "returns best time for specific difficulty" <|
                \_ ->
                    let
                        leaderBoard =
                            LeaderBoard.init
                                |> LeaderBoard.updateBestTime Beginner 90
                                |> LeaderBoard.updateBestTime Intermediate 180

                        beginnerTime =
                            LeaderBoard.getBestTime Beginner leaderBoard

                        intermediateTime =
                            LeaderBoard.getBestTime Intermediate leaderBoard

                        expertTime =
                            LeaderBoard.getBestTime Expert leaderBoard
                    in
                    Expect.all
                        [ \_ -> Expect.equal beginnerTime (Just 90)
                        , \_ -> Expect.equal intermediateTime (Just 180)
                        , \_ -> Expect.equal expertTime Nothing
                        ]
                        ()
            ]
        , describe "getAllBestTimes"
            [ test "returns empty list for empty leaderboard" <|
                \_ ->
                    let
                        result =
                            LeaderBoard.getAllBestTimes LeaderBoard.init
                    in
                    Expect.equal result []
            , test "returns all recorded times" <|
                \_ ->
                    let
                        leaderBoard =
                            LeaderBoard.init
                                |> LeaderBoard.updateBestTime Beginner 90
                                |> LeaderBoard.updateBestTime Expert 300

                        result =
                            LeaderBoard.getAllBestTimes leaderBoard
                    in
                    Expect.equal (List.length result) 2
            ]
        , describe "clearAll"
            [ test "resets leaderboard to empty state" <|
                \_ ->
                    let
                        originalLeaderBoard =
                            LeaderBoard.init
                                |> LeaderBoard.updateBestTime Beginner 90
                                |> LeaderBoard.updateBestTime Intermediate 180

                        clearedLeaderBoard =
                            LeaderBoard.clearAll
                    in
                    Expect.equal clearedLeaderBoard LeaderBoard.init
            ]
        , describe "encode/decode"
            [ test "encodes and decodes successfully" <|
                \_ ->
                    let
                        originalLeaderBoard =
                            LeaderBoard.init
                                |> LeaderBoard.updateBestTime Beginner 90
                                |> LeaderBoard.updateBestTime Intermediate 180

                        encoded =
                            LeaderBoard.encode originalLeaderBoard

                        decoded =
                            Decode.decodeValue LeaderBoard.decode encoded
                    in
                    case decoded of
                        Ok leaderBoard ->
                            Expect.equal leaderBoard originalLeaderBoard

                        Err _ ->
                            Expect.fail "Failed to decode leaderboard"
            , test "handles empty leaderboard encoding" <|
                \_ ->
                    let
                        emptyLeaderBoard =
                            LeaderBoard.init

                        encoded =
                            LeaderBoard.encode emptyLeaderBoard

                        decoded =
                            Decode.decodeValue LeaderBoard.decode encoded
                    in
                    case decoded of
                        Ok leaderBoard ->
                            Expect.equal leaderBoard emptyLeaderBoard

                        Err _ ->
                            Expect.fail "Failed to decode empty leaderboard"
            ]
        ]
