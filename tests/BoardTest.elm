module BoardTest exposing (..)

import Board
import Cell exposing (Position, State(..))
import Expect exposing (Expectation)
import Random
import Test exposing (..)


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
            , test "cells have correct positions" <|
                \_ ->
                    let
                        board =
                            Board.empty 3 3

                        firstRow =
                            List.head board |> Maybe.withDefault []

                        firstCell =
                            List.head firstRow |> Maybe.withDefault (Cell.create 0 0)
                    in
                    firstCell.position
                        |> Expect.equal { row = 0, col = 0 }
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
            , test "adjacent mine counting works correctly" <|
                \_ ->
                    let
                        seed =
                            Random.initialSeed 42

                        board =
                            Board.withMines 3 3 2 seed

                        -- Check that adjacentMines field is calculated
                        allCells =
                            List.concat board

                        cellsWithAdjacentMines =
                            List.filter (\cell -> cell.adjacentMines > 0) allCells
                    in
                    List.length cellsWithAdjacentMines
                        |> Expect.atLeast 1
            ]
        , describe "revealCell"
            [ test "reveals a hidden cell" <|
                \_ ->
                    let
                        seed =
                            Random.initialSeed 42

                        board =
                            Board.withMines 3 3 1 seed

                        revealedBoard =
                            Board.revealCell { row = 1, col = 1 } board

                        -- Get the cell at position (1, 1)
                        secondRow =
                            List.drop 1 revealedBoard |> List.head |> Maybe.withDefault []

                        middleCell =
                            List.drop 1 secondRow |> List.head |> Maybe.withDefault (Cell.create 1 1)
                    in
                    middleCell.state
                        |> Expect.equal Revealed
            , test "does not affect other cells when revealing" <|
                \_ ->
                    let
                        seed =
                            Random.initialSeed 42

                        board =
                            Board.withMines 3 3 1 seed

                        revealedBoard =
                            Board.revealCell { row = 1, col = 1 } board

                        -- Get the cell at position (0, 0) - should still be hidden
                        firstRow =
                            List.head revealedBoard |> Maybe.withDefault []

                        firstCell =
                            List.head firstRow |> Maybe.withDefault (Cell.create 0 0)
                    in
                    firstCell.state
                        |> Expect.equal Hidden
            ]
        ]


countMines : Board.Board -> Int
countMines board =
    board
        |> List.concat
        |> List.filter .isMine
        |> List.length


countNonMines : Board.Board -> Int
countNonMines board =
    board
        |> List.concat
        |> List.filter (\cell -> not cell.isMine)
        |> List.length


getMinePositions : Board.Board -> List Position
getMinePositions board =
    board
        |> List.concat
        |> List.filter .isMine
        |> List.map .position
        |> List.sortBy (\pos -> pos.row * 1000 + pos.col)
