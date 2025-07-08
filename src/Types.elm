module Types exposing (..)

import LeaderBoard exposing (Difficulty(..))
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
    , showLeaderBoardModal : Bool
    , showWinModal : Bool
    , leaderBoard : LeaderBoard.LeaderBoard
    }


type GameState
    = Playing
    | Won
    | Lost


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
    | ShowLeaderBoardModal
    | CloseLeaderBoardModal
    | ShowWinModal
    | CloseWinModal
    | ClearLeaderBoard
    | ViewportResize Int
    | LoadLeaderBoard
    | LeaderBoardLoaded (Maybe LeaderBoard.LeaderBoard)
    | NoOp
