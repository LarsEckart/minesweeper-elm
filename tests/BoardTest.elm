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
        , describe "withMinesAvoidingPosition"
            [ test "avoids placing mines at the specified position" <|
                \_ ->
                    let
                        seed =
                            Random.initialSeed 42

                        board =
                            Board.withMinesAvoidingPosition 9 9 10 seed 4 4

                        centerCell =
                            getCell board 4 4
                    in
                    case centerCell of
                        Just cell ->
                            cell.isMine
                                |> Expect.equal False

                        Nothing ->
                            Expect.fail "Could not get cell at position (4,4)"
            , test "avoids placing mines in adjacent positions" <|
                \_ ->
                    let
                        seed =
                            Random.initialSeed 42

                        board =
                            Board.withMinesAvoidingPosition 9 9 10 seed 4 4

                        adjacentPositions =
                            [ ( 3, 3 )
                            , ( 3, 4 )
                            , ( 3, 5 )
                            , ( 4, 3 )
                            , ( 4, 5 )
                            , ( 5, 3 )
                            , ( 5, 4 )
                            , ( 5, 5 )
                            ]

                        adjacentCells =
                            List.filterMap (\( row, col ) -> getCell board row col) adjacentPositions

                        hasAnyMines =
                            List.any .isMine adjacentCells
                    in
                    hasAnyMines
                        |> Expect.equal False
            , test "ensures clicked position has zero adjacent mines" <|
                \_ ->
                    let
                        seed =
                            Random.initialSeed 42

                        board =
                            Board.withMinesAvoidingPosition 9 9 10 seed 4 4

                        centerCell =
                            getCell board 4 4
                    in
                    case centerCell of
                        Just cell ->
                            cell.adjacentMines
                                |> Expect.equal 0

                        Nothing ->
                            Expect.fail "Could not get cell at position (4,4)"
            , test "creates board with correct mine count when avoiding position" <|
                \_ ->
                    let
                        seed =
                            Random.initialSeed 42

                        board =
                            Board.withMinesAvoidingPosition 9 9 10 seed 4 4

                        mineCount =
                            countMines board
                    in
                    mineCount
                        |> Expect.equal 10
            , test "different positions create different boards" <|
                \_ ->
                    let
                        seed =
                            Random.initialSeed 42

                        board1 =
                            Board.withMinesAvoidingPosition 9 9 10 seed 1 1

                        board2 =
                            Board.withMinesAvoidingPosition 9 9 10 seed 7 7

                        mines1 =
                            getMinePositions board1

                        mines2 =
                            getMinePositions board2
                    in
                    mines1
                        |> Expect.notEqual mines2
            ]
        , describe "win/loss detection"
            [ test "isLoss returns True when a mine is revealed" <|
                \_ ->
                    let
                        -- Create a small board with a mine at (0,0)
                        board =
                            Board.empty 2 2
                                |> placeMineAt 0 0
                                |> Board.revealCell 0 0
                    in
                    Board.isLoss board
                        |> Expect.equal True
            , test "isLoss returns False when no mines are revealed" <|
                \_ ->
                    let
                        -- Create a small board with a mine at (0,0) but don't reveal it
                        board =
                            Board.empty 2 2
                                |> placeMineAt 0 0
                                |> Board.revealCell 0 1
                    in
                    Board.isLoss board
                        |> Expect.equal False
            , test "isLoss returns False on empty board" <|
                \_ ->
                    let
                        board =
                            Board.empty 2 2
                    in
                    Board.isLoss board
                        |> Expect.equal False
            , test "isWin returns True when all non-mine cells are revealed" <|
                \_ ->
                    let
                        -- Create a 2x2 board with one mine at (0,0)
                        board =
                            Board.empty 2 2
                                |> placeMineAt 0 0
                                |> Board.revealCell 0 1
                                |> Board.revealCell 1 0
                                |> Board.revealCell 1 1
                    in
                    Board.isWin board
                        |> Expect.equal True
            , test "isWin returns False when some non-mine cells are hidden" <|
                \_ ->
                    let
                        -- Create a 2x2 board with one mine at (0,0), reveal only one non-mine cell
                        board =
                            Board.empty 2 2
                                |> placeMineAt 0 0
                                |> Board.revealCell 0 1
                    in
                    Board.isWin board
                        |> Expect.equal False
            , test "isWin returns False on empty board with no revealed cells" <|
                \_ ->
                    let
                        board =
                            Board.empty 2 2
                    in
                    Board.isWin board
                        |> Expect.equal False
            , test "isWin returns True on board with no mines when all cells revealed" <|
                \_ ->
                    let
                        board =
                            Board.empty 2 2
                                |> Board.revealCell 0 0
                                |> Board.revealCell 0 1
                                |> Board.revealCell 1 0
                                |> Board.revealCell 1 1
                    in
                    Board.isWin board
                        |> Expect.equal True
            , test "revealAllMines reveals all mines on the board" <|
                \_ ->
                    let
                        -- Create a 2x2 board with mines at (0,0) and (1,1)
                        board =
                            Board.empty 2 2
                                |> placeMineAt 0 0
                                |> placeMineAt 1 1
                                |> Board.revealAllMines
                                
                        mineAt00 =
                            getCell board 0 0
                            
                        mineAt11 =
                            getCell board 1 1
                            
                        nonMineAt01 =
                            getCell board 0 1
                    in
                    case (mineAt00, mineAt11, nonMineAt01) of
                        (Just cell00, Just cell11, Just cell01) ->
                            Expect.all
                                [ \_ -> cell00.state |> Expect.equal Revealed
                                , \_ -> cell11.state |> Expect.equal Revealed
                                , \_ -> cell01.state |> Expect.equal Hidden
                                ] ()
                        _ ->
                            Expect.fail "Could not get cells from board"
            , test "revealAllMines does not affect non-mine cells" <|
                \_ ->
                    let
                        -- Create a 2x2 board with one mine at (0,0), reveal a non-mine cell
                        board =
                            Board.empty 2 2
                                |> placeMineAt 0 0
                                |> Board.revealCell 0 1
                                |> Board.revealAllMines
                                
                        revealedNonMine =
                            getCell board 0 1
                            
                        hiddenNonMine =
                            getCell board 1 0
                    in
                    case (revealedNonMine, hiddenNonMine) of
                        (Just cell01, Just cell10) ->
                            Expect.all
                                [ \_ -> cell01.state |> Expect.equal Revealed
                                , \_ -> cell10.state |> Expect.equal Hidden
                                ] ()
                        _ ->
                            Expect.fail "Could not get cells from board"
            ]
        , describe "flood fill algorithm"
            [ test "revealCellWithFloodFill reveals single zero cell" <|
                \_ ->
                    let
                        -- Create a 3x3 board with no mines
                        board =
                            Board.empty 3 3
                                |> Board.revealCellWithFloodFill 1 1
                                
                        centerCell =
                            getCell board 1 1
                    in
                    case centerCell of
                        Just cell ->
                            cell.state
                                |> Expect.equal Revealed
                        Nothing ->
                            Expect.fail "Could not get center cell"
            , test "revealCellWithFloodFill reveals connected zero region" <|
                \_ ->
                    let
                        -- Create a 3x3 board with no mines (all zeros)
                        board =
                            Board.empty 3 3
                                |> Board.revealCellWithFloodFill 0 0
                                
                        allCells =
                            [ getCell board 0 0, getCell board 0 1, getCell board 0 2
                            , getCell board 1 0, getCell board 1 1, getCell board 1 2
                            , getCell board 2 0, getCell board 2 1, getCell board 2 2
                            ]
                                |> List.filterMap identity
                    in
                    allCells
                        |> List.all (\cell -> cell.state == Revealed)
                        |> Expect.equal True
            , test "revealCellWithFloodFill stops at border cells with numbers" <|
                \_ ->
                    let
                        -- Create a 3x3 board with one mine at (0,0)
                        board =
                            Board.empty 3 3
                                |> placeMineAt 0 0
                                |> calculateAdjacentMinesForBoard 3 3
                                |> Board.revealCellWithFloodFill 2 2
                                
                        -- Cell (2,2) should be revealed (it's zero)
                        bottomRightCell =
                            getCell board 2 2
                            
                        -- Cell (1,1) should be revealed (it's a number but connected to zero region)
                        centerCell =
                            getCell board 1 1
                            
                        -- Cell (0,1) should be revealed (it's a number but connected to zero region)
                        topMiddleCell =
                            getCell board 0 1
                            
                        -- Cell (1,0) should be revealed (it's a number but connected to zero region)
                        middleLeftCell =
                            getCell board 1 0
                    in
                    case (bottomRightCell, centerCell) of
                        (Just cell22, Just cell11) ->
                            case (topMiddleCell, middleLeftCell) of
                                (Just cell01, Just cell10) ->
                                    Expect.all
                                        [ \_ -> cell22.state |> Expect.equal Revealed
                                        , \_ -> cell11.state |> Expect.equal Revealed
                                        , \_ -> cell01.state |> Expect.equal Revealed
                                        , \_ -> cell10.state |> Expect.equal Revealed
                                        ] ()
                                _ ->
                                    Expect.fail "Could not get expected cells"
                        _ ->
                            Expect.fail "Could not get expected cells"
            , test "revealCellWithFloodFill does not reveal mines" <|
                \_ ->
                    let
                        -- Create a 3x3 board with mines at corners
                        board =
                            Board.empty 3 3
                                |> placeMineAt 0 0
                                |> placeMineAt 0 2
                                |> placeMineAt 2 0
                                |> placeMineAt 2 2
                                |> calculateAdjacentMinesForBoard 3 3
                                |> Board.revealCellWithFloodFill 1 1
                                
                        -- Center cell should be revealed (it's a number)
                        centerCell =
                            getCell board 1 1
                            
                        -- Corner mines should NOT be revealed
                        topLeftMine =
                            getCell board 0 0
                            
                        topRightMine =
                            getCell board 0 2
                            
                        bottomLeftMine =
                            getCell board 2 0
                            
                        bottomRightMine =
                            getCell board 2 2
                    in
                    case (centerCell, topLeftMine, topRightMine) of
                        (Just center, Just tl, Just tr) ->
                            case (bottomLeftMine, bottomRightMine) of
                                (Just bl, Just br) ->
                                    Expect.all
                                        [ \_ -> center.state |> Expect.equal Revealed
                                        , \_ -> tl.state |> Expect.equal Hidden
                                        , \_ -> tr.state |> Expect.equal Hidden
                                        , \_ -> bl.state |> Expect.equal Hidden
                                        , \_ -> br.state |> Expect.equal Hidden
                                        ] ()
                                _ ->
                                    Expect.fail "Could not get expected cells"
                        _ ->
                            Expect.fail "Could not get expected cells"
            , test "revealCellWithFloodFill handles already revealed cells" <|
                \_ ->
                    let
                        -- Create a 3x3 board with no mines, reveal center cell, then flood fill again
                        board =
                            Board.empty 3 3
                                |> Board.revealCell 1 1
                                |> Board.revealCellWithFloodFill 1 1
                                
                        centerCell =
                            getCell board 1 1
                    in
                    case centerCell of
                        Just cell ->
                            cell.state
                                |> Expect.equal Revealed
                        Nothing ->
                            Expect.fail "Could not get center cell"
            , test "revealCellWithFloodFill handles clicking on mine" <|
                \_ ->
                    let
                        -- Create a 3x3 board with mine at center
                        board =
                            Board.empty 3 3
                                |> placeMineAt 1 1
                                |> Board.revealCellWithFloodFill 1 1
                                
                        centerCell =
                            getCell board 1 1
                            
                        -- Other cells should remain hidden
                        cornerCell =
                            getCell board 0 0
                    in
                    case (centerCell, cornerCell) of
                        (Just mine, Just corner) ->
                            Expect.all
                                [ \_ -> mine.state |> Expect.equal Revealed
                                , \_ -> corner.state |> Expect.equal Hidden
                                ] ()
                        _ ->
                            Expect.fail "Could not get expected cells"
            , test "revealCellWithFloodFill handles invalid position" <|
                \_ ->
                    let
                        -- Create a 3x3 board and try to reveal invalid position
                        board =
                            Board.empty 3 3
                                |> Board.revealCellWithFloodFill 5 5
                                
                        -- Board should remain unchanged
                        allCells =
                            [ getCell board 0 0, getCell board 0 1, getCell board 0 2
                            , getCell board 1 0, getCell board 1 1, getCell board 1 2
                            , getCell board 2 0, getCell board 2 1, getCell board 2 2
                            ]
                                |> List.filterMap identity
                    in
                    allCells
                        |> List.all (\cell -> cell.state == Hidden)
                        |> Expect.equal True
            , test "revealCellWithFloodFill reveals border cells around zero region" <|
                \_ ->
                    let
                        -- Create a 5x5 board with mines in corners to create a zero region in center
                        board =
                            Board.empty 5 5
                                |> placeMineAt 0 0
                                |> placeMineAt 0 4
                                |> placeMineAt 4 0
                                |> placeMineAt 4 4
                                |> calculateAdjacentMinesForBoard 5 5
                                |> Board.revealCellWithFloodFill 2 2
                                
                        -- Center should be revealed (zero)
                        centerCell =
                            getCell board 2 2
                            
                        -- Adjacent cells should be revealed (numbers)
                        topCell =
                            getCell board 1 2
                            
                        bottomCell =
                            getCell board 3 2
                            
                        leftCell =
                            getCell board 2 1
                            
                        rightCell =
                            getCell board 2 3
                    in
                    case (centerCell, topCell, bottomCell) of
                        (Just center, Just top, Just bottom) ->
                            case (leftCell, rightCell) of
                                (Just left, Just right) ->
                                    Expect.all
                                        [ \_ -> center.state |> Expect.equal Revealed
                                        , \_ -> top.state |> Expect.equal Revealed
                                        , \_ -> bottom.state |> Expect.equal Revealed
                                        , \_ -> left.state |> Expect.equal Revealed
                                        , \_ -> right.state |> Expect.equal Revealed
                                        ] ()
                                _ ->
                                    Expect.fail "Could not get expected cells"
                        _ ->
                            Expect.fail "Could not get expected cells"
            ]
        , describe "toggleFlag"
            [ test "flags a hidden cell" <|
                \_ ->
                    let
                        board =
                            Board.empty 3 3
                                |> Board.toggleFlag 1 1
                                
                        flaggedCell =
                            getCell board 1 1
                    in
                    case flaggedCell of
                        Just cell ->
                            cell.state
                                |> Expect.equal Flagged
                        Nothing ->
                            Expect.fail "Could not get cell at position (1,1)"
            , test "unflags a flagged cell" <|
                \_ ->
                    let
                        board =
                            Board.empty 3 3
                                |> Board.toggleFlag 1 1
                                |> Board.toggleFlag 1 1
                                
                        unflaggedCell =
                            getCell board 1 1
                    in
                    case unflaggedCell of
                        Just cell ->
                            cell.state
                                |> Expect.equal Hidden
                        Nothing ->
                            Expect.fail "Could not get cell at position (1,1)"
            , test "does not affect revealed cells" <|
                \_ ->
                    let
                        board =
                            Board.empty 3 3
                                |> Board.revealCell 1 1
                                |> Board.toggleFlag 1 1
                                
                        revealedCell =
                            getCell board 1 1
                    in
                    case revealedCell of
                        Just cell ->
                            cell.state
                                |> Expect.equal Revealed
                        Nothing ->
                            Expect.fail "Could not get cell at position (1,1)"
            , test "does not affect other cells" <|
                \_ ->
                    let
                        board =
                            Board.empty 3 3
                                |> Board.toggleFlag 1 1
                                
                        otherCell =
                            getCell board 0 0
                    in
                    case otherCell of
                        Just cell ->
                            cell.state
                                |> Expect.equal Hidden
                        Nothing ->
                            Expect.fail "Could not get cell at position (0,0)"
            , test "handles invalid positions gracefully" <|
                \_ ->
                    let
                        board =
                            Board.empty 3 3
                                |> Board.toggleFlag 5 5
                                
                        -- Board should remain unchanged
                        centerCell =
                            getCell board 1 1
                    in
                    case centerCell of
                        Just cell ->
                            cell.state
                                |> Expect.equal Hidden
                        Nothing ->
                            Expect.fail "Could not get cell at position (1,1)"
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


{-| Helper function to place a mine at a specific position for testing -}
placeMineAt : Int -> Int -> Board -> Board
placeMineAt targetRow targetCol board =
    List.indexedMap
        (\row cells ->
            if row == targetRow then
                List.indexedMap
                    (\col cell ->
                        if col == targetCol then
                            { cell | isMine = True }
                        else
                            cell
                    )
                    cells
            else
                cells
        )
        board


{-| Helper function to calculate adjacent mines for a board (for testing) -}
calculateAdjacentMinesForBoard : Int -> Int -> Board -> Board
calculateAdjacentMinesForBoard rows cols board =
    List.indexedMap (calculateAdjacentMinesInRowForBoard rows cols board) board


calculateAdjacentMinesInRowForBoard : Int -> Int -> Board -> Int -> List Cell -> List Cell
calculateAdjacentMinesInRowForBoard rows cols board row cells =
    List.indexedMap (\col cell -> calculateAdjacentMinesInCellForBoard rows cols board row col cell) cells


calculateAdjacentMinesInCellForBoard : Int -> Int -> Board -> Int -> Int -> Cell -> Cell
calculateAdjacentMinesInCellForBoard rows cols board row col cell =
    if cell.isMine then
        cell
    else
        { cell | adjacentMines = countAdjacentMinesForBoard rows cols board row col }


countAdjacentMinesForBoard : Int -> Int -> Board -> Int -> Int -> Int
countAdjacentMinesForBoard rows cols board row col =
    getAdjacentPositionsForBoard rows cols row col
        |> List.map (getCellAtForBoard board)
        |> List.filter (Maybe.map .isMine >> Maybe.withDefault False)
        |> List.length


getAdjacentPositionsForBoard : Int -> Int -> Int -> Int -> List { row : Int, col : Int }
getAdjacentPositionsForBoard rows cols row col =
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


getCellAtForBoard : Board -> { row : Int, col : Int } -> Maybe Cell
getCellAtForBoard board position =
    board
        |> List.drop position.row
        |> List.head
        |> Maybe.andThen (List.drop position.col >> List.head)
