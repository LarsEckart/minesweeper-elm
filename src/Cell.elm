module Cell exposing (create, view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (on, onClick, preventDefaultOn)
import Json.Decode as Decode
import Style
import Time
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


view : (Int -> Int -> msg) -> (Int -> Int -> msg) -> (Int -> Int -> msg) -> (Int -> Int -> msg) -> Int -> Int -> Int -> Cell -> Html msg
view onCellClick onCellRightClick onCellTouchStart onCellTouchEnd cellSize row col cell =
    div
        [ Html.Attributes.class "cell"
        , style "width" (String.fromInt cellSize ++ "px")
        , style "height" (String.fromInt cellSize ++ "px")
        , style "border" ("2px solid " ++ Style.colors.border)
        , style "background-color" (getCellBackgroundColor cell)
        , style "display" "flex"
        , style "align-items" "center"
        , style "justify-content" "center"
        , style "cursor" "pointer"
        , style "user-select" "none"
        , style "font-weight" "bold"
        , style "font-size" (String.fromInt (max 12 (cellSize // 2)) ++ "px")
        , style "color" (Style.numberColors cell.adjacentMines)
        , style "border-radius" "4px"
        , style "box-shadow" ("0 2px 4px " ++ Style.colors.shadow)
        , style "transition" "all 0.2s ease"
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
            Style.colors.cellHidden

        Revealed ->
            if cell.isMine then
                Style.colors.cellMine

            else
                Style.colors.cellRevealed

        Flagged ->
            Style.colors.cellFlag


getNumberColor : Int -> String
getNumberColor count =
    Style.numberColors count
