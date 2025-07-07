module Main exposing (main)

import Board
import Browser
import Html exposing (Html, div, h1, text)
import Html.Attributes
import Random
import Types exposing (Board, GameState(..), Model, Msg(..))


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
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
            -- TODO: Implement right-click functionality for flagging
            ( model, Cmd.none )

        NewGame difficulty ->
            -- TODO: Implement new game functionality
            ( model, Cmd.none )

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
      }
    , Cmd.none
    )


handleCellClick : Int -> Int -> Model -> ( Model, Cmd Msg )
handleCellClick row col model =
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
      }
    , Cmd.none
    )


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
        , Board.view CellClicked model.board
        ]


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
