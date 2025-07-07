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
    }


create : Int -> Int -> Cell
create row col =
    { position = { row = row, col = col }
    , state = Hidden
    }


view : (Position -> msg) -> Cell -> Html msg
view onCellClick cell =
    div
        [ style "width" "30px"
        , style "height" "30px"
        , style "border" "1px solid #999"
        , style "background-color" "#ddd"
        , style "display" "flex"
        , style "align-items" "center"
        , style "justify-content" "center"
        , style "cursor" "pointer"
        , style "user-select" "none"
        , onClick (onCellClick cell.position)
        ]
        [ text (stateToString cell.state) ]


stateToString : State -> String
stateToString state =
    case state of
        Hidden ->
            ""

        Revealed ->
            "R"
