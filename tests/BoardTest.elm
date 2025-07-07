module BoardTest exposing (..)

import Board
import Cell exposing (Position, State(..))
import Expect exposing (Expectation)
import Test exposing (..)


suite : Test
suite =
    describe "Board module"
        [ describe "empty"
            [ test "creates a 9x9 board" <|
                \_ ->
                    let
                        board = Board.empty 9 9
                    in
                    board
                        |> List.length
                        |> Expect.equal 9
            , test "each row has 9 cells" <|
                \_ ->
                    let
                        board = Board.empty 9 9
                        firstRow = List.head board |> Maybe.withDefault []
                    in
                    firstRow
                        |> List.length
                        |> Expect.equal 9
            , test "cells have correct positions" <|
                \_ ->
                    let
                        board = Board.empty 3 3
                        firstRow = List.head board |> Maybe.withDefault []
                        firstCell = List.head firstRow |> Maybe.withDefault (Cell.create 0 0)
                    in
                    firstCell.position
                        |> Expect.equal { row = 0, col = 0 }
            , test "all cells start as Hidden" <|
                \_ ->
                    let
                        board = Board.empty 2 2
                        firstRow = List.head board |> Maybe.withDefault []
                        firstCell = List.head firstRow |> Maybe.withDefault (Cell.create 0 0)
                    in
                    firstCell.state
                        |> Expect.equal Hidden
            ]
        ]