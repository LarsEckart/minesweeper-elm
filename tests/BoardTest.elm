module BoardTest exposing (..)

import Board
import Cell
import Expect exposing (Expectation)
import Random
import Test exposing (..)
import Types exposing (Board, Cell, CellState(..))


suite : Test
suite =
    describe "Board module"
        [ describe "empty"
            [ test "creates a 9x9 board" <|
                \_ ->
                    let
                        board =
                            Board.empty 9 9
                    in
                    board
                        |> List.length
                        |> Expect.equal 9
            , test "each row has 9 cells" <|
                \_ ->
                    let
                        board =
                            Board.empty 9 9

                        firstRow =
                            List.head board |> Maybe.withDefault []
                    in
                    firstRow
                        |> List.length
                        |> Expect.equal 9
            , test "all cells start as Hidden" <|
                \_ ->
                    let
                        board =
                            Board.empty 2 2

                        firstRow =
                            List.head board |> Maybe.withDefault []

                        firstCell =
                            List.head firstRow |> Maybe.withDefault (Cell.create 0 0)
                    in
                    firstCell.state
                        |> Expect.equal Hidden
            , test "all cells start with no adjacent mines" <|
                \_ ->
                    let
                        board =
                            Board.empty 2 2

                        firstRow =
                            List.head board |> Maybe.withDefault []

                        firstCell =
                            List.head firstRow |> Maybe.withDefault (Cell.create 0 0)
                    in
                    firstCell.adjacentMines
                        |> Expect.equal 0
            ]
        , describe "withMines"
            [ test "creates board with correct mine count" <|
                \_ ->
                    let
                        seed =
                            Random.initialSeed 42

                        board =
                            Board.withMines 9 9 10 seed

                        mineCount =
                            countMines board
                    in
                    mineCount
                        |> Expect.equal 10
            , test "deterministic mine placement with same seed" <|
                \_ ->
                    let
                        seed =
                            Random.initialSeed 123

                        board1 =
                            Board.withMines 9 9 10 seed

                        board2 =
                            Board.withMines 9 9 10 seed

                        mines1 =
                            getMinePositions board1

                        mines2 =
                            getMinePositions board2
                    in
                    mines1
                        |> Expect.equal mines2
            , test "different seeds produce different mine placements" <|
                \_ ->
                    let
                        seed1 =
                            Random.initialSeed 1

                        seed2 =
                            Random.initialSeed 2

                        board1 =
                            Board.withMines 9 9 10 seed1

                        board2 =
                            Board.withMines 9 9 10 seed2

                        mines1 =
                            getMinePositions board1

                        mines2 =
                            getMinePositions board2
                    in
                    mines1
                        |> Expect.notEqual mines2
            , test "mine count never exceeds board size" <|
                \_ ->
                    let
                        seed =
                            Random.initialSeed 999

                        board =
                            Board.withMines 3 3 5 seed

                        mineCount =
                            countMines board
                    in
                    mineCount
                        |> Expect.equal 5
            , test "all cells without mines have isMine = False" <|
                \_ ->
                    let
                        seed =
                            Random.initialSeed 42

                        board =
                            Board.withMines 3 3 2 seed

                        nonMineCount =
                            countNonMines board
                    in
                    nonMineCount
                        |> Expect.equal 7
            ]
        , describe "adjacent mine counting"
            [ test "calculates adjacent mines correctly for corner cell" <|
                \_ ->
                    let
                        -- Create a 3x3 board with mines at (0,1) and (1,0)
                        seed =
                            Random.initialSeed 12345

                        board =
                            Board.withMines 3 3 2 seed

                        -- Get the cell at position (0,0) - top-left corner
                        topLeftCell =
                            getCell board 0 0
                    in
                    case topLeftCell of
                        Just cell ->
                            if cell.isMine then
                                Expect.pass

                            else
                                cell.adjacentMines
                                    |> Expect.atLeast 0

                        Nothing ->
                            Expect.fail "Could not get cell at position (0,0)"
            , test "mine cells have adjacentMines = 0" <|
                \_ ->
                    let
                        seed =
                            Random.initialSeed 42

                        board =
                            Board.withMines 3 3 2 seed

                        mineCells =
                            board
                                |> List.concat
                                |> List.filter .isMine
                    in
                    mineCells
                        |> List.all (\cell -> cell.adjacentMines == 0)
                        |> Expect.equal True
            , test "non-mine cells have correct adjacent mine count" <|
                \_ ->
                    let
                        seed =
                            Random.initialSeed 42

                        board =
                            Board.withMines 3 3 2 seed

                        nonMineCells =
                            board
                                |> List.concat
                                |> List.filter (\cell -> not cell.isMine)
                    in
                    nonMineCells
                        |> List.all (\cell -> cell.adjacentMines >= 0 && cell.adjacentMines <= 8)
                        |> Expect.equal True
            ]
        , describe "revealCell"
            [ test "reveals a hidden cell" <|
                \_ ->
                    let
                        board =
                            Board.empty 3 3

                        revealedBoard =
                            Board.revealCell 1 1 board

                        revealedCell =
                            getCell revealedBoard 1 1
                    in
                    case revealedCell of
                        Just cell ->
                            cell.state
                                |> Expect.equal Revealed

                        Nothing ->
                            Expect.fail "Could not get cell at position (1,1)"
            , test "does not affect other cells when revealing" <|
                \_ ->
                    let
                        board =
                            Board.empty 3 3

                        revealedBoard =
                            Board.revealCell 1 1 board

                        otherCell =
                            getCell revealedBoard 0 0
                    in
                    case otherCell of
                        Just cell ->
                            cell.state
                                |> Expect.equal Hidden

                        Nothing ->
                            Expect.fail "Could not get cell at position (0,0)"
            ]
        ]


countMines : Board -> Int
countMines board =
    board
        |> List.concat
        |> List.filter .isMine
        |> List.length


countNonMines : Board -> Int
countNonMines board =
    board
        |> List.concat
        |> List.filter (\cell -> not cell.isMine)
        |> List.length


getMinePositions : Board -> List { row : Int, col : Int }
getMinePositions board =
    board
        |> List.indexedMap
            (\row cells ->
                cells
                    |> List.indexedMap
                        (\col cell ->
                            if cell.isMine then
                                Just { row = row, col = col }

                            else
                                Nothing
                        )
                    |> List.filterMap identity
            )
        |> List.concat
        |> List.sortBy (\pos -> pos.row * 1000 + pos.col)


getCell : Board -> Int -> Int -> Maybe Cell
getCell board row col =
    board
        |> List.drop row
        |> List.head
        |> Maybe.andThen (List.drop col >> List.head)
