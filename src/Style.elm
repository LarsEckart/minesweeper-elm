module Style exposing
    ( Colors
    , cellSize
    , colors
    , gridGap
    , headerHeight
    , numberColors
    )


type alias Colors =
    { background : String
    , primary : String
    , secondary : String
    , accent : String
    , text : String
    , textSecondary : String
    , border : String
    , cellHidden : String
    , cellRevealed : String
    , cellMine : String
    , cellFlag : String
    , shadow : String
    , hover : String
    , active : String
    }


colors : Colors
colors =
    { background = "#FF6B35"
    , primary = "#F7931E"
    , secondary = "#FFD23F"
    , accent = "#06FFA5"
    , text = "#2C3E50"
    , textSecondary = "#7F8C8D"
    , border = "#E67E22"
    , cellHidden = "#F39C12"
    , cellRevealed = "#FFF3E0"
    , cellMine = "#E74C3C"
    , cellFlag = "#06FFA5"
    , shadow = "rgba(0, 0, 0, 0.3)"
    , hover = "rgba(255, 255, 255, 0.2)"
    , active = "rgba(0, 0, 0, 0.1)"
    }


cellSize : Int
cellSize =
    30


gridGap : Int
gridGap =
    2


headerHeight : Int
headerHeight =
    60


numberColors : Int -> String
numberColors adjacentMines =
    case adjacentMines of
        1 ->
            "#0000FF"

        2 ->
            "#008000"

        3 ->
            "#FF0000"

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
            colors.text
