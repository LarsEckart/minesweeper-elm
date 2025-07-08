module MainTest exposing (..)

import Expect
import LeaderBoard exposing (Difficulty(..))
import Main
import Test exposing (Test, describe, test)
import Timer
import Types exposing (GameState(..), Model, Msg(..))


suite : Test
suite =
    describe "Main module"
        [ describe "ResetGame message"
            [ test "resets game state to Playing" <|
                \_ ->
                    let
                        initialModel =
                            { board = []
                            , gameState = Lost
                            , difficulty = Beginner
                            , isFirstClick = False
                            , mineCount = 5
                            , touchStart = Nothing
                            , timer = Timer.start
                            , viewportWidth = 800
                            , showDifficultyModal = False
                            , showLeaderBoardModal = False
                            , showWinModal = False
                            , leaderBoard = LeaderBoard.init
                            }

                        ( updatedModel, _ ) =
                            Main.update ResetGame initialModel
                    in
                    Expect.equal updatedModel.gameState Playing
            , test "resets isFirstClick to True" <|
                \_ ->
                    let
                        initialModel =
                            { board = []
                            , gameState = Lost
                            , difficulty = Beginner
                            , isFirstClick = False
                            , mineCount = 5
                            , touchStart = Nothing
                            , timer = Timer.start
                            , viewportWidth = 800
                            , showDifficultyModal = False
                            , showLeaderBoardModal = False
                            , showWinModal = False
                            , leaderBoard = LeaderBoard.init
                            }

                        ( updatedModel, _ ) =
                            Main.update ResetGame initialModel
                    in
                    Expect.equal updatedModel.isFirstClick True
            , test "resets mine count to 10" <|
                \_ ->
                    let
                        initialModel =
                            { board = []
                            , gameState = Lost
                            , difficulty = Beginner
                            , isFirstClick = False
                            , mineCount = 5
                            , touchStart = Nothing
                            , timer = Timer.start
                            , viewportWidth = 800
                            , showDifficultyModal = False
                            , showLeaderBoardModal = False
                            , showWinModal = False
                            , leaderBoard = LeaderBoard.init
                            }

                        ( updatedModel, _ ) =
                            Main.update ResetGame initialModel
                    in
                    Expect.equal updatedModel.mineCount 10
            , test "resets timer" <|
                \_ ->
                    let
                        initialModel =
                            { board = []
                            , gameState = Lost
                            , difficulty = Beginner
                            , isFirstClick = False
                            , mineCount = 5
                            , touchStart = Nothing
                            , timer = Timer.start
                            , viewportWidth = 800
                            , showDifficultyModal = False
                            , showLeaderBoardModal = False
                            , showWinModal = False
                            , leaderBoard = LeaderBoard.init
                            }

                        ( updatedModel, _ ) =
                            Main.update ResetGame initialModel
                    in
                    Expect.equal updatedModel.timer Timer.init
            , test "generates new board with correct dimensions" <|
                \_ ->
                    let
                        initialModel =
                            { board = []
                            , gameState = Lost
                            , difficulty = Beginner
                            , isFirstClick = False
                            , mineCount = 5
                            , touchStart = Nothing
                            , timer = Timer.start
                            , viewportWidth = 800
                            , showDifficultyModal = False
                            , showLeaderBoardModal = False
                            , showWinModal = False
                            , leaderBoard = LeaderBoard.init
                            }

                        ( updatedModel, _ ) =
                            Main.update ResetGame initialModel
                    in
                    Expect.equal (List.length updatedModel.board) 9
            ]
        ]
