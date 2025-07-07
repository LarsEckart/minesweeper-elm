module Cell exposing (create, view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (on, onClick, preventDefaultOn)
import Json.Decode as Decode
import Types exposing (Cell, CellState(..))


type alias Position =
    { row : Int
    , col : Int
    }


create : Int -> Int -> Cell
create row col =
    { state = Hidden
    , isMine = False
    , adjacentMines = 0
    }


view : (Int -> Int -> msg) -> (Int -> Int -> msg) -> (Int -> Int -> msg) -> (Int -> Int -> msg) -> Int -> Int -> Cell -> Html msg
view onCellClick onCellRightClick onCellTouchStart onCellTouchEnd row col cell =
    div
        [ style "width" "30px"
        , style "height" "30px"
        , style "border" "1px solid #999"
        , style "background-color" (getCellBackgroundColor cell)
        , style "display" "flex"
        , style "align-items" "center"
        , style "justify-content" "center"
        , style "cursor" "pointer"
        , style "user-select" "none"
        , style "font-weight" "bold"
        , style "font-size" "14px"
        , style "color" (getNumberColor cell.adjacentMines)
        , onClick (onCellClick row col)
        , preventDefaultOn "contextmenu" (Decode.succeed ( onCellRightClick row col, True ))
        , on "touchstart" (Decode.succeed (onCellTouchStart row col))
        , on "touchend" (Decode.succeed (onCellTouchEnd row col))
        ]
        [ text (cellToString cell) ]


cellToString : Cell -> String
cellToString cell =
    case cell.state of
        Hidden ->
            ""

        Revealed ->
            if cell.isMine then
                "💣"

            else if cell.adjacentMines > 0 then
                String.fromInt cell.adjacentMines

            else
                ""

        Flagged ->
            "🚩"


getCellBackgroundColor : Cell -> String
getCellBackgroundColor cell =
    case cell.state of
        Hidden ->
            "#ddd"

        Revealed ->
            if cell.isMine then
                "#ff4444"

            else
                "#eee"

        Flagged ->
            "#ddd"


getNumberColor : Int -> String
getNumberColor count =
    case count of
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
            "#000000"
