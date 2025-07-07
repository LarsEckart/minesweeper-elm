module Main exposing (main)

import Board
import Browser
import Cell exposing (Position)
import Html exposing (Html, div, h1, text)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { board : Board.Board
    }


type Msg
    = CellClicked Position


init : () -> ( Model, Cmd Msg )
init _ =
    ( { board = Board.empty 9 9 }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CellClicked position ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Minesweeper" ]
        , Board.view CellClicked model.board
        ]
