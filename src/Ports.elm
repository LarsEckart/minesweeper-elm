port module Ports exposing (leaderboardLoaded, loadLeaderboard, saveLeaderboard)

import Json.Decode as Decode
import Json.Encode as Encode



-- Port for saving leaderboard data to localStorage


port saveLeaderboard : Encode.Value -> Cmd msg



-- Port for loading leaderboard data from localStorage


port loadLeaderboard : () -> Cmd msg



-- Port for receiving leaderboard data from localStorage


port leaderboardLoaded : (Decode.Value -> msg) -> Sub msg
