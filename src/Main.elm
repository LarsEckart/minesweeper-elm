module Main exposing (main)

import Board
import Browser
import Html exposing (Html, div, h1, text)
import Random
import Types exposing (Board)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { board : Board
    }


type Msg
    = CellClicked Int Int


init : () -> ( Model, Cmd Msg )
init _ =
    let
        seed =
            Random.initialSeed 42

        board =
            Board.withMines 9 9 10 seed
    in
    ( { board = board }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CellClicked row col ->
            ( { model | board = Board.revealCell row col model.board }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Minesweeper" ]
        , Board.view CellClicked model.board
        ]
