module TimerTest exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import Timer


suite : Test
suite =
    describe "Timer"
        [ describe "init"
            [ test "creates a stopped timer" <|
                \_ ->
                    Timer.init
                        |> Timer.getSeconds
                        |> Expect.equal 0
            ]
        , describe "start"
            [ test "starts a timer at 0 seconds" <|
                \_ ->
                    Timer.start
                        |> Timer.getSeconds
                        |> Expect.equal 0
            ]
        , describe "tick"
            [ test "increments running timer by 1 second" <|
                \_ ->
                    Timer.start
                        |> Timer.tick
                        |> Timer.getSeconds
                        |> Expect.equal 1
            , test "does not increment stopped timer" <|
                \_ ->
                    Timer.init
                        |> Timer.tick
                        |> Timer.getSeconds
                        |> Expect.equal 0
            ]
        , describe "stop"
            [ test "stops a running timer" <|
                \_ ->
                    Timer.start
                        |> Timer.tick
                        |> Timer.tick
                        |> Timer.stop
                        |> Timer.tick
                        |> Timer.getSeconds
                        |> Expect.equal 0
            ]
        , describe "formatTime"
            [ test "formats seconds under 60" <|
                \_ ->
                    Timer.formatTime 45
                        |> Expect.equal "45"
            , test "formats exactly 60 seconds" <|
                \_ ->
                    Timer.formatTime 60
                        |> Expect.equal "1:00"
            , test "formats minutes and seconds" <|
                \_ ->
                    Timer.formatTime 125
                        |> Expect.equal "2:05"
            , test "pads single digit seconds" <|
                \_ ->
                    Timer.formatTime 61
                        |> Expect.equal "1:01"
            ]
        ]
