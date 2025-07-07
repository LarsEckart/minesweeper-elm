module Board exposing (empty, revealCell, view, withMines, withMinesAvoidingPosition)

import Array
import Cell
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Random
import Types exposing (Board, Cell, CellState(..))


empty : Int -> Int -> Board
empty rows cols =
    List.range 0 (rows - 1)
        |> List.map
            (\row ->
                List.range 0 (cols - 1)
                    |> List.map (\col -> Cell.create row col)
            )


view : (Int -> Int -> msg) -> Board -> Html msg
view onCellClick board =
    div
        [ style "display" "grid"
        , style "grid-template-columns" "repeat(9, 30px)"
        , style "gap" "1px"
        , style "border" "1px solid #ccc"
        , style "padding" "10px"
        , style "background-color" "#f0f0f0"
        ]
        (List.concat (List.indexedMap (viewRow onCellClick) board))


viewRow : (Int -> Int -> msg) -> Int -> List Cell -> List (Html msg)
viewRow onCellClick row cells =
    List.indexedMap (\col cell -> Cell.view onCellClick row col cell) cells


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
