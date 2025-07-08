module Types exposing (..)

import Time
import Timer


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
    , mineCount : Int
    , touchStart : Maybe { row : Int, col : Int, time : Time.Posix }
    , timer : Timer.Timer
    , viewportWidth : Int
    , showDifficultyModal : Bool
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
    | CellTouchStart Int Int
    | CellTouchEnd Int Int
    | TouchStartWithTime Int Int Time.Posix
    | TouchEndWithTime Int Int Time.Posix
    | NewGame Difficulty
    | TimerTick Time.Posix
    | ResetGame
    | ShowDifficultyModal
    | ViewportResize Int
    | NoOp
