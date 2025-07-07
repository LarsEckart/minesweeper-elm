<<<<<<< HEAD
module Board exposing (Board, empty, view, withMines)

import Array
import Cell exposing (Cell, Position)
=======
module Board exposing (Board, empty, revealCell, view, withMines)

import Cell exposing (Cell, Position, State(..))
>>>>>>> 681b99e (TASK-4 Implement Task 4: Adjacent Mine Counting)
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Random


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


<<<<<<< HEAD
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
    List.map (placeMinesInRow minePositions) board


placeMinesInRow : List Position -> List Cell -> List Cell
placeMinesInRow minePositions cells =
    List.map (placeMineInCell minePositions) cells


placeMineInCell : List Position -> Cell -> Cell
placeMineInCell minePositions cell =
    if List.any (\pos -> pos.row == cell.position.row && pos.col == cell.position.col) minePositions then
        { cell | isMine = True }
=======
withMines : List Position -> Board -> Board
withMines minePositions board =
    board
        |> List.map (List.map (placeMine minePositions))
        |> calculateAdjacentMines


placeMine : List Position -> Cell -> Cell
placeMine minePositions cell =
    { cell | isMine = List.member cell.position minePositions }


calculateAdjacentMines : Board -> Board
calculateAdjacentMines board =
    List.map (List.map (calculateCellAdjacentMines board)) board


calculateCellAdjacentMines : Board -> Cell -> Cell
calculateCellAdjacentMines board cell =
    { cell | adjacentMines = countAdjacentMines board cell.position }


countAdjacentMines : Board -> Position -> Int
countAdjacentMines board position =
    getAdjacentPositions position
        |> List.map (getCellAt board)
        |> List.filterMap identity
        |> List.filter .isMine
        |> List.length


getAdjacentPositions : Position -> List Position
getAdjacentPositions pos =
    [ { row = pos.row - 1, col = pos.col - 1 }
    , { row = pos.row - 1, col = pos.col }
    , { row = pos.row - 1, col = pos.col + 1 }
    , { row = pos.row, col = pos.col - 1 }
    , { row = pos.row, col = pos.col + 1 }
    , { row = pos.row + 1, col = pos.col - 1 }
    , { row = pos.row + 1, col = pos.col }
    , { row = pos.row + 1, col = pos.col + 1 }
    ]


getCellAt : Board -> Position -> Maybe Cell
getCellAt board position =
    if position.row < 0 || position.col < 0 then
        Nothing

    else
        board
            |> List.drop position.row
            |> List.head
            |> Maybe.andThen (List.drop position.col >> List.head)


revealCell : Position -> Board -> Board
revealCell position board =
    List.map (List.map (revealCellIfMatch position)) board


revealCellIfMatch : Position -> Cell -> Cell
revealCellIfMatch targetPosition cell =
    if cell.position == targetPosition then
        { cell | state = Revealed }
>>>>>>> 681b99e (TASK-4 Implement Task 4: Adjacent Mine Counting)

    else
        cell
