module Board exposing (empty, isLoss, isWin, revealAllMines, revealCell, revealCellWithFloodFill, toggleFlag, view, withMines, withMinesAvoidingPosition)

import Array
import Cell
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Random
import Style
import Time
import Types exposing (Board, Cell, CellState(..))


empty : Int -> Int -> Board
empty rows cols =
    List.range 0 (rows - 1)
        |> List.map
            (\row ->
                List.range 0 (cols - 1)
                    |> List.map (\col -> Cell.create row col)
            )


view : (Int -> Int -> msg) -> (Int -> Int -> msg) -> (Int -> Int -> msg) -> (Int -> Int -> msg) -> Int -> Board -> Html msg
view onCellClick onCellRightClick onCellTouchStart onCellTouchEnd viewportWidth board =
    let
        -- Calculate actual board dimensions
        cols =
            List.head board |> Maybe.map List.length |> Maybe.withDefault 0

        cellSize =
            Style.responsiveCellSize viewportWidth cols

        gridGap =
            Style.responsiveGridGap viewportWidth

        borderWidth =
            if viewportWidth < 480 then
                2

            else
                3

        padding =
            if viewportWidth < 480 then
                10

            else
                20
    in
    div
        [ Html.Attributes.class "grid"
        , style "display" "grid"
        , style "grid-template-columns" ("repeat(" ++ String.fromInt cols ++ ", " ++ String.fromInt cellSize ++ "px)")
        , style "gap" (String.fromInt gridGap ++ "px")
        , style "border" (String.fromInt borderWidth ++ "px solid " ++ Style.colors.border)
        , style "padding" (String.fromInt padding ++ "px")
        , style "background-color" Style.colors.secondary
        , style "border-radius" "12px"
        , style "box-shadow" ("0 6px 12px " ++ Style.colors.shadow)
        , style "margin" "20px auto"
        , style "max-width" "fit-content"
        ]
        (List.concat (List.indexedMap (viewRow onCellClick onCellRightClick onCellTouchStart onCellTouchEnd cellSize) board))


viewRow : (Int -> Int -> msg) -> (Int -> Int -> msg) -> (Int -> Int -> msg) -> (Int -> Int -> msg) -> Int -> Int -> List Cell -> List (Html msg)
viewRow onCellClick onCellRightClick onCellTouchStart onCellTouchEnd cellSize row cells =
    List.indexedMap (\col cell -> Cell.view onCellClick onCellRightClick onCellTouchStart onCellTouchEnd cellSize row col cell) cells


withMines : Int -> Int -> Int -> Random.Seed -> Board
withMines rows cols mineCount seed =
    let
        totalCells =
            rows * cols

        positions =
            generateAllPositions rows cols

        ( minePositions, _ ) =
            Random.step (selectRandomPositions mineCount positions) seed
    in
    empty rows cols
        |> placeMines minePositions
        |> calculateAdjacentMines rows cols


withMinesAvoidingPosition : Int -> Int -> Int -> Random.Seed -> Int -> Int -> Board
withMinesAvoidingPosition rows cols mineCount seed avoidRow avoidCol =
    let
        avoidPosition =
            { row = avoidRow, col = avoidCol }

        avoidPositions =
            avoidPosition :: getAdjacentPositions rows cols avoidRow avoidCol

        availablePositions =
            generateAllPositions rows cols
                |> List.filter (\pos -> not (List.member pos avoidPositions))

        ( minePositions, _ ) =
            Random.step (selectRandomPositions mineCount availablePositions) seed
    in
    empty rows cols
        |> placeMines minePositions
        |> calculateAdjacentMines rows cols


type alias Position =
    { row : Int
    , col : Int
    }


generateAllPositions : Int -> Int -> List Position
generateAllPositions rows cols =
    List.range 0 (rows - 1)
        |> List.concatMap
            (\row ->
                List.range 0 (cols - 1)
                    |> List.map (\col -> { row = row, col = col })
            )


selectRandomPositions : Int -> List Position -> Random.Generator (List Position)
selectRandomPositions count positions =
    Random.map (List.take count) (shuffleList positions)


shuffleList : List a -> Random.Generator (List a)
shuffleList list =
    list
        |> Array.fromList
        |> shuffleArray
        |> Random.map Array.toList


shuffleArray : Array.Array a -> Random.Generator (Array.Array a)
shuffleArray array =
    let
        length =
            Array.length array
    in
    shuffleArrayHelper (length - 1) array


shuffleArrayHelper : Int -> Array.Array a -> Random.Generator (Array.Array a)
shuffleArrayHelper i array =
    if i <= 0 then
        Random.constant array

    else
        Random.int 0 i
            |> Random.andThen
                (\j ->
                    case ( Array.get i array, Array.get j array ) of
                        ( Just a, Just b ) ->
                            array
                                |> Array.set i b
                                |> Array.set j a
                                |> shuffleArrayHelper (i - 1)

                        _ ->
                            shuffleArrayHelper (i - 1) array
                )


placeMines : List Position -> Board -> Board
placeMines minePositions board =
    List.indexedMap (placeMinesInRow minePositions) board


placeMinesInRow : List Position -> Int -> List Cell -> List Cell
placeMinesInRow minePositions row cells =
    List.indexedMap (\col cell -> placeMineInCell minePositions row col cell) cells


placeMineInCell : List Position -> Int -> Int -> Cell -> Cell
placeMineInCell minePositions row col cell =
    if List.any (\pos -> pos.row == row && pos.col == col) minePositions then
        { cell | isMine = True }

    else
        cell


calculateAdjacentMines : Int -> Int -> Board -> Board
calculateAdjacentMines rows cols board =
    List.indexedMap (calculateAdjacentMinesInRow rows cols board) board


calculateAdjacentMinesInRow : Int -> Int -> Board -> Int -> List Cell -> List Cell
calculateAdjacentMinesInRow rows cols board row cells =
    List.indexedMap (\col cell -> calculateAdjacentMinesInCell rows cols board row col cell) cells


calculateAdjacentMinesInCell : Int -> Int -> Board -> Int -> Int -> Cell -> Cell
calculateAdjacentMinesInCell rows cols board row col cell =
    if cell.isMine then
        cell

    else
        { cell | adjacentMines = countAdjacentMines rows cols board row col }


countAdjacentMines : Int -> Int -> Board -> Int -> Int -> Int
countAdjacentMines rows cols board row col =
    getAdjacentPositions rows cols row col
        |> List.map (getCellAt board)
        |> List.filter (Maybe.map .isMine >> Maybe.withDefault False)
        |> List.length


getAdjacentPositions : Int -> Int -> Int -> Int -> List Position
getAdjacentPositions rows cols row col =
    [ { row = row - 1, col = col - 1 }
    , { row = row - 1, col = col }
    , { row = row - 1, col = col + 1 }
    , { row = row, col = col - 1 }
    , { row = row, col = col + 1 }
    , { row = row + 1, col = col - 1 }
    , { row = row + 1, col = col }
    , { row = row + 1, col = col + 1 }
    ]
        |> List.filter (\pos -> pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols)


getCellAt : Board -> Position -> Maybe Cell
getCellAt board position =
    board
        |> List.drop position.row
        |> List.head
        |> Maybe.andThen (List.drop position.col >> List.head)


revealCell : Int -> Int -> Board -> Board
revealCell row col board =
    List.indexedMap
        (\r cells ->
            if r == row then
                List.indexedMap
                    (\c cell ->
                        if c == col then
                            { cell | state = Revealed }

                        else
                            cell
                    )
                    cells

            else
                cells
        )
        board


{-| Reveal a cell with flood fill logic for zero cells
-}
revealCellWithFloodFill : Int -> Int -> Board -> Board
revealCellWithFloodFill row col board =
    let
        rows =
            List.length board

        cols =
            List.head board |> Maybe.map List.length |> Maybe.withDefault 0

        clickedCell =
            getCellAt board { row = row, col = col }
    in
    case clickedCell of
        Just cell ->
            if cell.state == Revealed then
                -- Cell already revealed, no action needed
                board

            else if cell.isMine then
                -- Just reveal the mine, no flood fill
                revealCell row col board

            else if cell.adjacentMines == 0 then
                -- Zero cell, trigger flood fill
                floodFill rows cols board { row = row, col = col }

            else
                -- Number cell, just reveal it
                revealCell row col board

        Nothing ->
            -- Invalid position, no action
            board


{-| Flood fill algorithm that reveals connected zero cells and their border cells
-}
floodFill : Int -> Int -> Board -> Position -> Board
floodFill rows cols board startPosition =
    let
        -- Set to track visited positions to avoid infinite loops
        visited =
            []

        -- Queue for BFS flood fill
        queue =
            [ startPosition ]

        -- Use helper function to process the flood fill
        result =
            floodFillHelper rows cols board visited queue
    in
    result.board


{-| Helper function for flood fill using BFS approach
-}
floodFillHelper : Int -> Int -> Board -> List Position -> List Position -> { board : Board, visited : List Position }
floodFillHelper rows cols board visited queue =
    case queue of
        [] ->
            -- No more positions to process
            { board = board, visited = visited }

        currentPos :: remainingQueue ->
            if List.member currentPos visited then
                -- Already visited this position, skip it
                floodFillHelper rows cols board visited remainingQueue

            else
                case getCellAt board currentPos of
                    Just cell ->
                        if cell.state == Revealed then
                            -- Already revealed, skip
                            floodFillHelper rows cols board visited remainingQueue

                        else
                            -- Reveal this cell
                            let
                                newBoard =
                                    revealCell currentPos.row currentPos.col board

                                newVisited =
                                    currentPos :: visited
                            in
                            if cell.adjacentMines == 0 && not cell.isMine then
                                -- This is a zero cell, add its neighbors to the queue
                                let
                                    neighbors =
                                        getAdjacentPositions rows cols currentPos.row currentPos.col

                                    newQueue =
                                        remainingQueue ++ neighbors
                                in
                                floodFillHelper rows cols newBoard newVisited newQueue

                            else
                                -- This is a border cell (has adjacent mines), don't expand further
                                floodFillHelper rows cols newBoard newVisited remainingQueue

                    Nothing ->
                        -- Invalid position, skip
                        floodFillHelper rows cols board visited remainingQueue


{-| Check if the game is lost by determining if a mine was revealed
-}
isLoss : Board -> Bool
isLoss board =
    board
        |> List.concat
        |> List.any (\cell -> cell.isMine && cell.state == Revealed)


{-| Check if the game is won by determining if all non-mine cells are revealed
-}
isWin : Board -> Bool
isWin board =
    board
        |> List.concat
        |> List.filter (\cell -> not cell.isMine)
        |> List.all (\cell -> cell.state == Revealed)


{-| Reveal all mines on the board (used when game is lost)
-}
revealAllMines : Board -> Board
revealAllMines board =
    List.map
        (\row ->
            List.map
                (\cell ->
                    if cell.isMine then
                        { cell | state = Revealed }

                    else
                        cell
                )
                row
        )
        board


{-| Toggle flag state of a cell
-}
toggleFlag : Int -> Int -> Board -> Board
toggleFlag row col board =
    List.indexedMap
        (\r cells ->
            if r == row then
                List.indexedMap
                    (\c cell ->
                        if c == col then
                            case cell.state of
                                Hidden ->
                                    { cell | state = Flagged }

                                Flagged ->
                                    { cell | state = Hidden }

                                Revealed ->
                                    cell

                        else
                            cell
                    )
                    cells

            else
                cells
        )
        board
