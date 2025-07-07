module Types exposing (..)


type CellState
    = Hidden
    | Revealed
    | Flagged


type alias Cell =
    { state : CellState
    , isMine : Bool
    , adjacentMines : Int
    }


type alias Board =
    List (List Cell)


type alias Model =
    { board : Board
    , gameState : GameState
    , difficulty : Difficulty
    , isFirstClick : Bool
    }


type GameState
    = Playing
    | Won
    | Lost


type Difficulty
    = Beginner
    | Intermediate
    | Expert


type Msg
    = CellClicked Int Int
    | CellRightClicked Int Int
    | NewGame Difficulty
    | NoOp
