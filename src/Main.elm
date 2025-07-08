module Main exposing (main, update)

import Board
import Browser
import Browser.Events
import Html exposing (Html, button, div, h1, text)
import Html.Attributes
import Html.Events
import Json.Decode as Decode
import LeaderBoard exposing (Difficulty(..))
import Modal
import Ports
import Random
import Style
import Task
import Time
import Timer
import Types exposing (Board, GameState(..), Model, Msg(..))


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { board = []
      , gameState = Playing
      , difficulty = Beginner
      , isFirstClick = True
      , mineCount = 10
      , touchStart = Nothing
      , timer = Timer.init
      , viewportWidth = 800
      , showDifficultyModal = True
      , showLeaderBoardModal = False
      , showWinModal = False
      , leaderBoard = LeaderBoard.init
      }
    , Cmd.batch
        [ Task.perform ViewportResize (Task.succeed 800)
        , Ports.loadLeaderboard ()
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CellClicked row col ->
            -- Don't allow clicks if game is over
            if model.gameState /= Playing then
                ( model, Cmd.none )

            else if model.isFirstClick then
                handleFirstClick row col model

            else
                handleCellClick row col model

        CellRightClicked row col ->
            handleRightClick row col model

        CellTouchStart row col ->
            ( model, Task.perform (TouchStartWithTime row col) Time.now )

        CellTouchEnd row col ->
            ( model, Task.perform (TouchEndWithTime row col) Time.now )

        TouchStartWithTime row col time ->
            handleTouchStart row col time model

        TouchEndWithTime row col time ->
            handleTouchEnd row col time model

        NewGame difficulty ->
            let
                seed =
                    Random.initialSeed 42

                ( rows, cols, mines ) =
                    case difficulty of
                        Beginner ->
                            ( 9, 9, 10 )

                        Intermediate ->
                            ( 12, 12, 25 )

                        Expert ->
                            ( 15, 15, 50 )

                newBoard =
                    Board.withMines rows cols mines seed
            in
            ( { model
                | board = newBoard
                , gameState = Playing
                , difficulty = difficulty
                , isFirstClick = True
                , mineCount = mines
                , timer = Timer.init
                , showDifficultyModal = False
                , showWinModal = False
              }
            , Cmd.none
            )

        ResetGame ->
            let
                seed =
                    Random.initialSeed 42

                ( rows, cols, mines ) =
                    case model.difficulty of
                        Beginner ->
                            ( 9, 9, 10 )

                        Intermediate ->
                            ( 12, 12, 25 )

                        Expert ->
                            ( 15, 15, 50 )

                newBoard =
                    Board.withMines rows cols mines seed
            in
            ( { model
                | board = newBoard
                , gameState = Playing
                , isFirstClick = True
                , mineCount = mines
                , timer = Timer.init
                , showWinModal = False
              }
            , Cmd.none
            )

        TimerTick _ ->
            ( { model | timer = Timer.tick model.timer }, Cmd.none )

        ShowDifficultyModal ->
            ( { model | showDifficultyModal = True }, Cmd.none )

        ShowLeaderBoardModal ->
            ( { model | showLeaderBoardModal = True }, Cmd.none )

        CloseLeaderBoardModal ->
            ( { model | showLeaderBoardModal = False }, Cmd.none )

        ShowWinModal ->
            ( { model | showWinModal = True }, Cmd.none )

        CloseWinModal ->
            ( { model | showWinModal = False }, Cmd.none )

        ClearLeaderBoard ->
            let
                clearedLeaderBoard =
                    LeaderBoard.clearAll
            in
            ( { model | leaderBoard = clearedLeaderBoard }
            , Ports.saveLeaderboard (LeaderBoard.encode clearedLeaderBoard)
            )

        ViewportResize width ->
            ( { model | viewportWidth = width }, Cmd.none )

        LoadLeaderBoard ->
            ( model, Ports.loadLeaderboard () )

        LeaderBoardLoaded maybeLeaderBoard ->
            let
                leaderBoard =
                    case maybeLeaderBoard of
                        Just lb ->
                            lb

                        Nothing ->
                            LeaderBoard.init
            in
            ( { model | leaderBoard = leaderBoard }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


handleFirstClick : Int -> Int -> Model -> ( Model, Cmd Msg )
handleFirstClick row col model =
    let
        -- Check if the clicked cell would be a mine
        clickedCell =
            getCellAt model.board row col

        needsRegeneration =
            case clickedCell of
                Just cell ->
                    cell.isMine || cell.adjacentMines > 0

                Nothing ->
                    False

        newBoard =
            if needsRegeneration then
                -- Regenerate board avoiding the clicked position and its neighbors
                let
                    seed =
                        Random.initialSeed 42

                    ( rows, cols, mines ) =
                        case model.difficulty of
                            Beginner ->
                                ( 9, 9, 10 )

                            Intermediate ->
                                ( 12, 12, 25 )

                            Expert ->
                                ( 15, 15, 50 )
                in
                Board.withMinesAvoidingPosition rows cols mines seed row col

            else
                model.board

        updatedBoard =
            Board.revealCellWithFloodFill row col newBoard

        -- Check win/loss conditions after first click
        newGameState =
            if Board.isLoss updatedBoard then
                Lost

            else if Board.isWin updatedBoard then
                Won

            else
                Playing

        -- Reveal all mines if game is lost
        finalBoard =
            if newGameState == Lost then
                Board.revealAllMines updatedBoard

            else
                updatedBoard

        -- Update leaderboard and save if game is won
        ( updatedLeaderBoard, saveCmd ) =
            if newGameState == Won then
                let
                    finalTime =
                        Timer.getSeconds model.timer

                    newLeaderBoard =
                        LeaderBoard.updateBestTime model.difficulty finalTime model.leaderBoard
                in
                ( newLeaderBoard, Ports.saveLeaderboard (LeaderBoard.encode newLeaderBoard) )

            else
                ( model.leaderBoard, Cmd.none )

        -- Show win modal when game is won
        updatedShowWinModal =
            if newGameState == Won then
                True

            else
                model.showWinModal

        -- Update timer based on game state
        updatedTimer =
            case newGameState of
                Playing ->
                    Timer.start

                _ ->
                    Timer.stop model.timer
    in
    ( { model
        | board = finalBoard
        , gameState = newGameState
        , isFirstClick = False
        , timer = updatedTimer
        , leaderBoard = updatedLeaderBoard
        , showWinModal = updatedShowWinModal
      }
    , saveCmd
    )


handleCellClick : Int -> Int -> Model -> ( Model, Cmd Msg )
handleCellClick row col model =
    let
        -- Check if the clicked cell is flagged
        clickedCell =
            getCellAt model.board row col

        -- Don't reveal flagged cells
        canReveal =
            case clickedCell of
                Just cell ->
                    cell.state /= Types.Flagged

                Nothing ->
                    False
    in
    if canReveal then
        let
            updatedBoard =
                Board.revealCellWithFloodFill row col model.board

            -- Check win/loss conditions after click
            newGameState =
                if Board.isLoss updatedBoard then
                    Lost

                else if Board.isWin updatedBoard then
                    Won

                else
                    Playing

            -- Reveal all mines if game is lost
            finalBoard =
                if newGameState == Lost then
                    Board.revealAllMines updatedBoard

                else
                    updatedBoard

            -- Update leaderboard and save if game is won
            ( updatedLeaderBoard, saveCmd ) =
                if newGameState == Won then
                    let
                        finalTime =
                            Timer.getSeconds model.timer

                        newLeaderBoard =
                            LeaderBoard.updateBestTime model.difficulty finalTime model.leaderBoard
                    in
                    ( newLeaderBoard, Ports.saveLeaderboard (LeaderBoard.encode newLeaderBoard) )

                else
                    ( model.leaderBoard, Cmd.none )

            -- Show win modal when game is won
            updatedShowWinModal =
                if newGameState == Won then
                    True

                else
                    model.showWinModal

            -- Update timer based on game state
            updatedTimer =
                if newGameState /= Playing then
                    Timer.stop model.timer

                else
                    model.timer
        in
        ( { model
            | board = finalBoard
            , gameState = newGameState
            , timer = updatedTimer
            , leaderBoard = updatedLeaderBoard
            , showWinModal = updatedShowWinModal
          }
        , saveCmd
        )

    else
        ( model, Cmd.none )


handleRightClick : Int -> Int -> Model -> ( Model, Cmd Msg )
handleRightClick row col model =
    -- Don't allow flagging if game is over
    if model.gameState /= Playing then
        ( model, Cmd.none )

    else
        let
            -- Get the current cell to check its state
            clickedCell =
                getCellAt model.board row col

            newBoard =
                Board.toggleFlag row col model.board

            -- Update mine counter based on flag change
            newMineCount =
                case clickedCell of
                    Just cell ->
                        if cell.state == Types.Hidden then
                            -- Flagging a cell, decrease mine count
                            model.mineCount - 1

                        else if cell.state == Types.Flagged then
                            -- Unflagging a cell, increase mine count
                            model.mineCount + 1

                        else
                            -- Revealed cells can't be flagged
                            model.mineCount

                    Nothing ->
                        model.mineCount
        in
        ( { model
            | board = newBoard
            , mineCount = newMineCount
          }
        , Cmd.none
        )


handleTouchStart : Int -> Int -> Time.Posix -> Model -> ( Model, Cmd Msg )
handleTouchStart row col time model =
    -- Don't handle touch if game is over
    if model.gameState /= Playing then
        ( model, Cmd.none )

    else
        -- Record the touch start with timestamp
        ( { model | touchStart = Just { row = row, col = col, time = time } }
        , Cmd.none
        )


handleTouchEnd : Int -> Int -> Time.Posix -> Model -> ( Model, Cmd Msg )
handleTouchEnd row col endTime model =
    -- Don't handle touch if game is over
    if model.gameState /= Playing then
        ( model, Cmd.none )

    else
        case model.touchStart of
            Just touchData ->
                if touchData.row == row && touchData.col == col then
                    -- Same cell, check if it was a long press (500ms)
                    let
                        duration =
                            Time.posixToMillis endTime - Time.posixToMillis touchData.time

                        updatedModel =
                            { model | touchStart = Nothing }
                    in
                    if duration >= 500 then
                        -- Long press, flag the cell
                        handleRightClick row col updatedModel

                    else
                    -- Short tap, reveal the cell
                    if
                        model.isFirstClick
                    then
                        handleFirstClick row col updatedModel

                    else
                        handleCellClick row col updatedModel

                else
                    -- Different cell, reset touch state
                    ( { model | touchStart = Nothing }, Cmd.none )

            Nothing ->
                -- No touch start recorded, treat as regular click
                if model.isFirstClick then
                    handleFirstClick row col model

                else
                    handleCellClick row col model


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        timerSub =
            case model.gameState of
                Playing ->
                    Time.every 1000 TimerTick

                _ ->
                    Sub.none

        viewportSub =
            Browser.Events.onResize (\w _ -> ViewportResize w)

        leaderboardSub =
            Ports.leaderboardLoaded
                (\value ->
                    case Decode.decodeValue (Decode.nullable LeaderBoard.decode) value of
                        Ok maybeLeaderBoard ->
                            LeaderBoardLoaded maybeLeaderBoard

                        Err _ ->
                            LeaderBoardLoaded Nothing
                )
    in
    Sub.batch [ timerSub, viewportSub, leaderboardSub ]


getCellAt : Board -> Int -> Int -> Maybe Types.Cell
getCellAt board row col =
    board
        |> List.drop row
        |> List.head
        |> Maybe.andThen (List.drop col >> List.head)


view : Model -> Html Msg
view model =
    let
        padding =
            if model.viewportWidth < 480 then
                "5px"

            else if model.viewportWidth < 768 then
                "10px"

            else
                "20px"

        gameContent =
            [ h1
                [ Html.Attributes.style "text-align" "center"
                , Html.Attributes.style "color" Style.colors.text
                , Html.Attributes.style "margin-bottom" "20px"
                , Html.Attributes.style "text-shadow" "2px 2px 4px rgba(0,0,0,0.3)"
                ]
                [ text "Minesweeper" ]
            , gameStatusView model.gameState
            , headerBarView model
            , Board.view CellClicked CellRightClicked CellTouchStart CellTouchEnd model.viewportWidth model.board
            ]

        modalContent =
            if model.showDifficultyModal then
                [ Modal.difficultySelectionModal ]

            else if model.showLeaderBoardModal then
                [ Modal.leaderBoardModal model.leaderBoard ]

            else if model.showWinModal then
                [ Modal.winModal model.difficulty (Timer.getSeconds model.timer) model.leaderBoard ]

            else
                []
    in
    div
        [ Html.Attributes.style "background-color" Style.colors.background
        , Html.Attributes.style "min-height" "100vh"
        , Html.Attributes.style "padding" padding
        , Html.Attributes.style "font-family" "Arial, sans-serif"
        , Html.Attributes.style "overflow-x" "auto"
        ]
        (gameContent ++ modalContent)


headerBarView : Model -> Html Msg
headerBarView model =
    let
        padding =
            if model.viewportWidth < 480 then
                "10px 15px"

            else
                "15px 25px"

        borderWidth =
            if model.viewportWidth < 480 then
                "2px"

            else
                "3px"
    in
    div
        [ Html.Attributes.style "display" "flex"
        , Html.Attributes.style "justify-content" "space-between"
        , Html.Attributes.style "align-items" "center"
        , Html.Attributes.style "padding" padding
        , Html.Attributes.style "border" (borderWidth ++ " solid " ++ Style.colors.border)
        , Html.Attributes.style "border-radius" "12px"
        , Html.Attributes.style "background-color" Style.colors.primary
        , Html.Attributes.style "margin" "20px auto"
        , Html.Attributes.style "max-width" "400px"
        , Html.Attributes.style "box-shadow" ("0 4px 8px " ++ Style.colors.shadow)
        ]
        [ div
            [ Html.Attributes.style "display" "flex"
            , Html.Attributes.style "align-items" "center"
            , Html.Attributes.style "gap" "10px"
            ]
            [ headerMineCounterView model.mineCount
            , headerDifficultyButtonView model.difficulty
            , headerLeaderBoardButtonView
            ]
        , headerResetButtonView model.gameState
        , headerTimerView model.timer
        ]


headerMineCounterView : Int -> Html Msg
headerMineCounterView mineCount =
    div
        [ Html.Attributes.style "font-size" "18px"
        , Html.Attributes.style "font-weight" "bold"
        , Html.Attributes.style "color" Style.colors.text
        , Html.Attributes.style "background-color" Style.colors.cellRevealed
        , Html.Attributes.style "padding" "8px 12px"
        , Html.Attributes.style "border-radius" "6px"
        , Html.Attributes.style "border" ("2px solid " ++ Style.colors.border)
        ]
        [ text ("💣 " ++ String.fromInt mineCount) ]


headerDifficultyButtonView : Difficulty -> Html Msg
headerDifficultyButtonView difficulty =
    let
        difficultyText =
            case difficulty of
                Beginner ->
                    "B"

                Intermediate ->
                    "I"

                Expert ->
                    "E"
    in
    button
        [ Html.Events.onClick ShowDifficultyModal
        , Html.Attributes.style "font-size" "14px"
        , Html.Attributes.style "font-weight" "bold"
        , Html.Attributes.style "color" Style.colors.text
        , Html.Attributes.style "background-color" Style.colors.accent
        , Html.Attributes.style "padding" "6px 10px"
        , Html.Attributes.style "border-radius" "6px"
        , Html.Attributes.style "border" ("2px solid " ++ Style.colors.border)
        , Html.Attributes.style "cursor" "pointer"
        , Html.Attributes.style "transition" "all 0.2s ease"
        ]
        [ text difficultyText ]


headerLeaderBoardButtonView : Html Msg
headerLeaderBoardButtonView =
    button
        [ Html.Events.onClick ShowLeaderBoardModal
        , Html.Attributes.style "font-size" "14px"
        , Html.Attributes.style "font-weight" "bold"
        , Html.Attributes.style "color" Style.colors.text
        , Html.Attributes.style "background-color" Style.colors.accent
        , Html.Attributes.style "padding" "6px 10px"
        , Html.Attributes.style "border-radius" "6px"
        , Html.Attributes.style "border" ("2px solid " ++ Style.colors.border)
        , Html.Attributes.style "cursor" "pointer"
        , Html.Attributes.style "transition" "all 0.2s ease"
        ]
        [ text "🏆" ]


headerResetButtonView : GameState -> Html Msg
headerResetButtonView gameState =
    let
        emoji =
            case gameState of
                Playing ->
                    "🙂"

                Won ->
                    "😎"

                Lost ->
                    "😵"
    in
    button
        [ Html.Events.onClick ResetGame
        , Html.Attributes.style "font-size" "28px"
        , Html.Attributes.style "padding" "10px 14px"
        , Html.Attributes.style "border" ("3px solid " ++ Style.colors.border)
        , Html.Attributes.style "border-radius" "8px"
        , Html.Attributes.style "background-color" Style.colors.secondary
        , Html.Attributes.style "cursor" "pointer"
        , Html.Attributes.style "box-shadow" ("0 2px 4px " ++ Style.colors.shadow)
        , Html.Attributes.style "transition" "all 0.2s ease"
        ]
        [ text emoji ]


headerTimerView : Timer.Timer -> Html Msg
headerTimerView timer =
    let
        seconds =
            Timer.getSeconds timer

        timeText =
            Timer.formatTime seconds
    in
    div
        [ Html.Attributes.style "font-size" "18px"
        , Html.Attributes.style "font-weight" "bold"
        , Html.Attributes.style "color" Style.colors.text
        , Html.Attributes.style "background-color" Style.colors.cellRevealed
        , Html.Attributes.style "padding" "8px 12px"
        , Html.Attributes.style "border-radius" "6px"
        , Html.Attributes.style "border" ("2px solid " ++ Style.colors.border)
        ]
        [ text ("⏱️ " ++ timeText) ]


mineCounterView : Int -> Html Msg
mineCounterView mineCount =
    div [ Html.Attributes.style "font-size" "16px", Html.Attributes.style "margin" "10px 0", Html.Attributes.style "font-weight" "bold" ]
        [ text ("💣 " ++ String.fromInt mineCount) ]


resetButtonView : GameState -> Html Msg
resetButtonView gameState =
    let
        emoji =
            case gameState of
                Playing ->
                    "🙂"

                Won ->
                    "😎"

                Lost ->
                    "😵"
    in
    div [ Html.Attributes.style "text-align" "center", Html.Attributes.style "margin" "10px 0" ]
        [ button
            [ Html.Events.onClick ResetGame
            , Html.Attributes.style "font-size" "24px"
            , Html.Attributes.style "padding" "8px 12px"
            , Html.Attributes.style "border" "2px solid #ccc"
            , Html.Attributes.style "border-radius" "6px"
            , Html.Attributes.style "background-color" "#f0f0f0"
            , Html.Attributes.style "cursor" "pointer"
            ]
            [ text emoji ]
        ]


timerView : Timer.Timer -> Html Msg
timerView timer =
    let
        seconds =
            Timer.getSeconds timer

        timeText =
            Timer.formatTime seconds
    in
    div [ Html.Attributes.style "font-size" "16px", Html.Attributes.style "margin" "10px 0", Html.Attributes.style "font-weight" "bold" ]
        [ text ("⏱️ " ++ timeText) ]


gameStatusView : GameState -> Html Msg
gameStatusView gameState =
    case gameState of
        Playing ->
            div
                [ Html.Attributes.style "color" Style.colors.text
                , Html.Attributes.style "font-size" "20px"
                , Html.Attributes.style "margin" "15px 0"
                , Html.Attributes.style "text-align" "center"
                , Html.Attributes.style "background-color" Style.colors.accent
                , Html.Attributes.style "padding" "10px"
                , Html.Attributes.style "border-radius" "8px"
                , Html.Attributes.style "border" ("2px solid " ++ Style.colors.border)
                ]
                [ text "Playing..." ]

        Won ->
            div
                [ Html.Attributes.style "color" Style.colors.text
                , Html.Attributes.style "font-size" "22px"
                , Html.Attributes.style "margin" "15px 0"
                , Html.Attributes.style "font-weight" "bold"
                , Html.Attributes.style "text-align" "center"
                , Html.Attributes.style "background-color" Style.colors.accent
                , Html.Attributes.style "padding" "15px"
                , Html.Attributes.style "border-radius" "8px"
                , Html.Attributes.style "border" ("3px solid " ++ Style.colors.border)
                , Html.Attributes.style "box-shadow" ("0 4px 8px " ++ Style.colors.shadow)
                ]
                [ text "🎉 Congratulations! You won! 🎉" ]

        Lost ->
            div
                [ Html.Attributes.style "color" Style.colors.text
                , Html.Attributes.style "font-size" "22px"
                , Html.Attributes.style "margin" "15px 0"
                , Html.Attributes.style "font-weight" "bold"
                , Html.Attributes.style "text-align" "center"
                , Html.Attributes.style "background-color" Style.colors.cellMine
                , Html.Attributes.style "padding" "15px"
                , Html.Attributes.style "border-radius" "8px"
                , Html.Attributes.style "border" ("3px solid " ++ Style.colors.border)
                , Html.Attributes.style "box-shadow" ("0 4px 8px " ++ Style.colors.shadow)
                ]
                [ text "💥 Game Over! You hit a mine! 💥" ]
