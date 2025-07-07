module Main exposing (main)

import Board
import Browser
import Html exposing (Html, div, h1, text)
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
            if model.isFirstClick then
                handleFirstClick row col model

            else
                ( { model | board = Board.revealCell row col model.board }, Cmd.none )

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
            Board.revealCell row col newBoard
    in
    ( { model
        | board = updatedBoard
        , isFirstClick = False
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
        , Board.view CellClicked model.board
        ]
