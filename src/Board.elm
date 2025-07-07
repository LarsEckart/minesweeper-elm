module Board exposing (Board, empty, view)

import Cell exposing (Cell, Position)
import Html exposing (Html, div)
import Html.Attributes exposing (style)


type alias Board =
    List (List Cell)


empty : Int -> Int -> Board
empty rows cols =
    List.range 0 (rows - 1)
        |> List.map
            (\row ->
                List.range 0 (cols - 1)
                    |> List.map (\col -> Cell.create row col)
            )


view : (Position -> msg) -> Board -> Html msg
view onCellClick board =
    div 
        [ style "display" "grid"
        , style "grid-template-columns" "repeat(9, 30px)"
        , style "gap" "1px"
        , style "border" "1px solid #ccc"
        , style "padding" "10px"
        , style "background-color" "#f0f0f0"
        ]
        (List.concat (List.map (viewRow onCellClick) board))


viewRow : (Position -> msg) -> List Cell -> List (Html msg)
viewRow onCellClick cells =
    List.map (Cell.view onCellClick) cells
