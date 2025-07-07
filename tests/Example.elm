module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


suite : Test
suite =
    describe "Example test suite"
        [ test "basic math" <|
            \_ ->
                Expect.equal (2 + 2) 4
        ]
