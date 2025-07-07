module Cell exposing (Cell, Position, State(..), create, view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)


type alias Position =
    { row : Int
    , col : Int
    }


type State
    = Hidden
    | Revealed


type alias Cell =
    { position : Position
    , state : State
    , isMine : Bool
    , adjacentMines : Int
    }


create : Int -> Int -> Cell
create row col =
    { position = { row = row, col = col }
    , state = Hidden
    , isMine = False
    , adjacentMines = 0
    }


view : (Position -> msg) -> Cell -> Html msg
view onCellClick cell =
    div
        [ style "width" "30px"
        , style "height" "30px"
        , style "border" "1px solid #999"
        , style "background-color" (cellBackgroundColor cell)
        , style "display" "flex"
        , style "align-items" "center"
        , style "justify-content" "center"
        , style "cursor" "pointer"
        , style "user-select" "none"
        , style "font-weight" "bold"
        , style "color" (numberColor cell)
        , onClick (onCellClick cell.position)
        ]
        [ text (cellContent cell) ]


cellContent : Cell -> String
cellContent cell =
    case cell.state of
        Hidden ->
            if cell.isMine then
                "💣"

            else
                ""

        Revealed ->
            if cell.isMine then
                "💣"

            else if cell.adjacentMines > 0 then
                String.fromInt cell.adjacentMines

            else
                ""


cellBackgroundColor : Cell -> String
cellBackgroundColor cell =
    case cell.state of
        Hidden ->
            "#ddd"

        Revealed ->
            if cell.isMine then
                "#ff6b6b"

            else
                "#eee"


numberColor : Cell -> String
numberColor cell =
    case cell.state of
        Hidden ->
            "#000"

        Revealed ->
            if cell.isMine then
                "#fff"

            else
                case cell.adjacentMines of
                    1 ->
                        "#0000ff"

                    2 ->
                        "#008000"

                    3 ->
                        "#ff0000"

                    4 ->
                        "#000080"

                    5 ->
                        "#800000"

                    6 ->
                        "#008080"

                    7 ->
                        "#000000"

                    8 ->
                        "#808080"

                    _ ->
                        "#000"
