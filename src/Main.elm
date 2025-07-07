module Main exposing (main, update)

import Board
import Browser
import Html exposing (Html, button, div, h1, text)
import Html.Attributes
import Html.Events
import Random
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
    let
        seed =
            Random.initialSeed 42

        board =
            Board.withMines 9 9 10 seed
    in
    ( { board = board
      , gameState = Playing
      , difficulty = Types.Beginner
      , isFirstClick = True
      , mineCount = 10
      , touchStart = Nothing
      , timer = Timer.init
      }
    , Cmd.none
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
            -- TODO: Implement new game functionality
            ( model, Cmd.none )

        ResetGame ->
            let
                seed =
                    Random.initialSeed 42

                newBoard =
                    Board.withMines 9 9 10 seed
            in
            ( { model
                | board = newBoard
                , gameState = Playing
                , isFirstClick = True
                , mineCount = 10
                , timer = Timer.init
              }
            , Cmd.none
            )

        TimerTick _ ->
            ( { model | timer = Timer.tick model.timer }, Cmd.none )

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
                in
                Board.withMinesAvoidingPosition 9 9 10 seed row col

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
    in
    ( { model
        | board = finalBoard
        , gameState = newGameState
        , isFirstClick = False
        , timer = Timer.start
      }
    , Cmd.none
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
        in
        ( { model
            | board = finalBoard
            , gameState = newGameState
            , timer =
                if newGameState /= Playing then
                    Timer.stop model.timer

                else
                    model.timer
          }
        , Cmd.none
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
    case model.gameState of
        Playing ->
            Time.every 1000 TimerTick

        _ ->
            Sub.none


getCellAt : Board -> Int -> Int -> Maybe Types.Cell
getCellAt board row col =
    board
        |> List.drop row
        |> List.head
        |> Maybe.andThen (List.drop col >> List.head)


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Minesweeper" ]
        , gameStatusView model.gameState
        , mineCounterView model.mineCount
        , resetButtonView model.gameState
        , timerView model.timer
        , Board.view CellClicked CellRightClicked CellTouchStart CellTouchEnd model.board
        ]


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
            div [ Html.Attributes.style "color" "blue", Html.Attributes.style "font-size" "18px", Html.Attributes.style "margin" "10px 0" ]
                [ text "Playing..." ]

        Won ->
            div [ Html.Attributes.style "color" "green", Html.Attributes.style "font-size" "18px", Html.Attributes.style "margin" "10px 0", Html.Attributes.style "font-weight" "bold" ]
                [ text "Congratulations! You won!" ]

        Lost ->
            div [ Html.Attributes.style "color" "red", Html.Attributes.style "font-size" "18px", Html.Attributes.style "margin" "10px 0", Html.Attributes.style "font-weight" "bold" ]
                [ text "Game Over! You hit a mine!" ]
