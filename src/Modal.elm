module Modal exposing (difficultySelectionModal, leaderBoardModal, winModal)

import Html exposing (Html, button, div, h2, h3, p, text)
import Html.Attributes
import Html.Events
import LeaderBoard exposing (Difficulty(..))
import Style
import Timer
import Types exposing (Msg(..))


difficultySelectionModal : Html Msg
difficultySelectionModal =
    div
        [ Html.Attributes.style "position" "fixed"
        , Html.Attributes.style "top" "0"
        , Html.Attributes.style "left" "0"
        , Html.Attributes.style "width" "100%"
        , Html.Attributes.style "height" "100%"
        , Html.Attributes.style "background-color" "rgba(0,0,0,0.5)"
        , Html.Attributes.style "display" "flex"
        , Html.Attributes.style "justify-content" "center"
        , Html.Attributes.style "align-items" "center"
        , Html.Attributes.style "z-index" "1000"
        ]
        [ div
            [ Html.Attributes.style "background-color" Style.colors.background
            , Html.Attributes.style "padding" "40px"
            , Html.Attributes.style "border-radius" "15px"
            , Html.Attributes.style "border" ("3px solid " ++ Style.colors.border)
            , Html.Attributes.style "box-shadow" ("0 8px 16px " ++ Style.colors.shadow)
            , Html.Attributes.style "max-width" "500px"
            , Html.Attributes.style "text-align" "center"
            ]
            [ h2
                [ Html.Attributes.style "color" Style.colors.text
                , Html.Attributes.style "margin-bottom" "20px"
                , Html.Attributes.style "text-shadow" "2px 2px 4px rgba(0,0,0,0.3)"
                ]
                [ text "Choose Difficulty" ]
            , p
                [ Html.Attributes.style "color" Style.colors.text
                , Html.Attributes.style "margin-bottom" "30px"
                , Html.Attributes.style "font-size" "16px"
                ]
                [ text "Select your preferred difficulty level to start playing" ]
            , div
                [ Html.Attributes.style "display" "flex"
                , Html.Attributes.style "flex-direction" "column"
                , Html.Attributes.style "gap" "15px"
                ]
                [ difficultyButton "Beginner" "9x9, 10 mines" Beginner
                , difficultyButton "Intermediate" "12x12, 25 mines" Intermediate
                , difficultyButton "Expert" "15x15, 50 mines" Expert
                ]
            ]
        ]


leaderBoardModal : LeaderBoard.LeaderBoard -> Html Msg
leaderBoardModal leaderBoard =
    div
        [ Html.Attributes.style "position" "fixed"
        , Html.Attributes.style "top" "0"
        , Html.Attributes.style "left" "0"
        , Html.Attributes.style "width" "100%"
        , Html.Attributes.style "height" "100%"
        , Html.Attributes.style "background-color" "rgba(0,0,0,0.5)"
        , Html.Attributes.style "display" "flex"
        , Html.Attributes.style "justify-content" "center"
        , Html.Attributes.style "align-items" "center"
        , Html.Attributes.style "z-index" "1000"
        ]
        [ div
            [ Html.Attributes.style "background-color" Style.colors.background
            , Html.Attributes.style "padding" "40px"
            , Html.Attributes.style "border-radius" "15px"
            , Html.Attributes.style "border" ("3px solid " ++ Style.colors.border)
            , Html.Attributes.style "box-shadow" ("0 8px 16px " ++ Style.colors.shadow)
            , Html.Attributes.style "max-width" "400px"
            , Html.Attributes.style "text-align" "center"
            ]
            [ h2
                [ Html.Attributes.style "color" Style.colors.text
                , Html.Attributes.style "margin-bottom" "20px"
                , Html.Attributes.style "text-shadow" "2px 2px 4px rgba(0,0,0,0.3)"
                ]
                [ text "🏆 Leaderboard" ]
            , div
                [ Html.Attributes.style "text-align" "left"
                , Html.Attributes.style "margin-bottom" "30px"
                ]
                [ bestTimeEntry "Beginner (9×9)" (LeaderBoard.getBestTime Beginner leaderBoard)
                , bestTimeEntry "Intermediate (12×12)" (LeaderBoard.getBestTime Intermediate leaderBoard)
                , bestTimeEntry "Expert (15×15)" (LeaderBoard.getBestTime Expert leaderBoard)
                ]
            , div
                [ Html.Attributes.style "display" "flex"
                , Html.Attributes.style "gap" "15px"
                , Html.Attributes.style "justify-content" "center"
                ]
                [ button
                    [ Html.Events.onClick ClearLeaderBoard
                    , Html.Attributes.style "background-color" Style.colors.cellMine
                    , Html.Attributes.style "color" Style.colors.text
                    , Html.Attributes.style "border" ("2px solid " ++ Style.colors.border)
                    , Html.Attributes.style "border-radius" "8px"
                    , Html.Attributes.style "padding" "12px 24px"
                    , Html.Attributes.style "cursor" "pointer"
                    , Html.Attributes.style "font-size" "16px"
                    , Html.Attributes.style "font-weight" "bold"
                    , Html.Attributes.style "transition" "all 0.3s ease"
                    , Html.Attributes.style "box-shadow" ("0 2px 4px " ++ Style.colors.shadow)
                    ]
                    [ text "Clear Records" ]
                , button
                    [ Html.Events.onClick CloseLeaderBoardModal
                    , Html.Attributes.style "background-color" Style.colors.primary
                    , Html.Attributes.style "color" Style.colors.text
                    , Html.Attributes.style "border" ("2px solid " ++ Style.colors.border)
                    , Html.Attributes.style "border-radius" "8px"
                    , Html.Attributes.style "padding" "12px 24px"
                    , Html.Attributes.style "cursor" "pointer"
                    , Html.Attributes.style "font-size" "16px"
                    , Html.Attributes.style "font-weight" "bold"
                    , Html.Attributes.style "transition" "all 0.3s ease"
                    , Html.Attributes.style "box-shadow" ("0 2px 4px " ++ Style.colors.shadow)
                    ]
                    [ text "Close" ]
                ]
            ]
        ]


bestTimeEntry : String -> Maybe Int -> Html Msg
bestTimeEntry difficultyName maybeBestTime =
    div
        [ Html.Attributes.style "display" "flex"
        , Html.Attributes.style "justify-content" "space-between"
        , Html.Attributes.style "align-items" "center"
        , Html.Attributes.style "padding" "12px 0"
        , Html.Attributes.style "border-bottom" ("1px solid " ++ Style.colors.border)
        ]
        [ div
            [ Html.Attributes.style "color" Style.colors.text
            , Html.Attributes.style "font-weight" "bold"
            ]
            [ text difficultyName ]
        , div
            [ Html.Attributes.style "color" Style.colors.text
            , Html.Attributes.style "font-family" "monospace"
            ]
            [ text
                (case maybeBestTime of
                    Just seconds ->
                        Timer.formatTime seconds

                    Nothing ->
                        "No record"
                )
            ]
        ]


winModal : Difficulty -> Int -> LeaderBoard.LeaderBoard -> Html Msg
winModal difficulty currentTime leaderBoard =
    let
        currentBestTime =
            LeaderBoard.getBestTime difficulty leaderBoard

        isNewRecord =
            case currentBestTime of
                Nothing ->
                    True

                Just bestTime ->
                    currentTime < bestTime

        difficultyText =
            case difficulty of
                Beginner ->
                    "Beginner"

                Intermediate ->
                    "Intermediate"

                Expert ->
                    "Expert"
    in
    div
        [ Html.Attributes.style "position" "fixed"
        , Html.Attributes.style "top" "0"
        , Html.Attributes.style "left" "0"
        , Html.Attributes.style "width" "100%"
        , Html.Attributes.style "height" "100%"
        , Html.Attributes.style "background-color" "rgba(0,0,0,0.5)"
        , Html.Attributes.style "display" "flex"
        , Html.Attributes.style "justify-content" "center"
        , Html.Attributes.style "align-items" "center"
        , Html.Attributes.style "z-index" "1000"
        ]
        [ div
            [ Html.Attributes.style "background-color" Style.colors.background
            , Html.Attributes.style "padding" "40px"
            , Html.Attributes.style "border-radius" "15px"
            , Html.Attributes.style "border" ("3px solid " ++ Style.colors.border)
            , Html.Attributes.style "box-shadow" ("0 8px 16px " ++ Style.colors.shadow)
            , Html.Attributes.style "max-width" "450px"
            , Html.Attributes.style "text-align" "center"
            ]
            [ h2
                [ Html.Attributes.style "color" Style.colors.text
                , Html.Attributes.style "margin-bottom" "20px"
                , Html.Attributes.style "text-shadow" "2px 2px 4px rgba(0,0,0,0.3)"
                ]
                [ text "🎉 Congratulations! 🎉" ]
            , p
                [ Html.Attributes.style "color" Style.colors.text
                , Html.Attributes.style "margin-bottom" "20px"
                , Html.Attributes.style "font-size" "18px"
                , Html.Attributes.style "font-weight" "bold"
                ]
                [ text ("You completed " ++ difficultyText ++ " mode!") ]
            , div
                [ Html.Attributes.style "margin-bottom" "20px"
                , Html.Attributes.style "padding" "15px"
                , Html.Attributes.style "background-color" Style.colors.primary
                , Html.Attributes.style "border-radius" "10px"
                , Html.Attributes.style "border" ("2px solid " ++ Style.colors.border)
                ]
                [ div
                    [ Html.Attributes.style "color" Style.colors.text
                    , Html.Attributes.style "font-size" "16px"
                    , Html.Attributes.style "margin-bottom" "10px"
                    ]
                    [ text ("Your Time: " ++ Timer.formatTime currentTime) ]
                , div
                    [ Html.Attributes.style "color" Style.colors.text
                    , Html.Attributes.style "font-size" "16px"
                    ]
                    [ text
                        ("Best Time: "
                            ++ (case currentBestTime of
                                    Nothing ->
                                        "No record"

                                    Just bestTime ->
                                        Timer.formatTime bestTime
                               )
                        )
                    ]
                , if isNewRecord then
                    div
                        [ Html.Attributes.style "color" Style.colors.accent
                        , Html.Attributes.style "font-size" "18px"
                        , Html.Attributes.style "font-weight" "bold"
                        , Html.Attributes.style "margin-top" "10px"
                        ]
                        [ text "🏆 New Record!" ]

                  else
                    text ""
                ]
            , div
                [ Html.Attributes.style "display" "flex"
                , Html.Attributes.style "gap" "15px"
                , Html.Attributes.style "justify-content" "center"
                ]
                [ button
                    [ Html.Events.onClick ResetGame
                    , Html.Attributes.style "background-color" Style.colors.secondary
                    , Html.Attributes.style "color" Style.colors.text
                    , Html.Attributes.style "border" ("2px solid " ++ Style.colors.border)
                    , Html.Attributes.style "border-radius" "8px"
                    , Html.Attributes.style "padding" "12px 24px"
                    , Html.Attributes.style "cursor" "pointer"
                    , Html.Attributes.style "font-size" "16px"
                    , Html.Attributes.style "font-weight" "bold"
                    , Html.Attributes.style "transition" "all 0.3s ease"
                    , Html.Attributes.style "box-shadow" ("0 2px 4px " ++ Style.colors.shadow)
                    ]
                    [ text "Play Again" ]
                , button
                    [ Html.Events.onClick CloseWinModal
                    , Html.Attributes.style "background-color" Style.colors.primary
                    , Html.Attributes.style "color" Style.colors.text
                    , Html.Attributes.style "border" ("2px solid " ++ Style.colors.border)
                    , Html.Attributes.style "border-radius" "8px"
                    , Html.Attributes.style "padding" "12px 24px"
                    , Html.Attributes.style "cursor" "pointer"
                    , Html.Attributes.style "font-size" "16px"
                    , Html.Attributes.style "font-weight" "bold"
                    , Html.Attributes.style "transition" "all 0.3s ease"
                    , Html.Attributes.style "box-shadow" ("0 2px 4px " ++ Style.colors.shadow)
                    ]
                    [ text "Close" ]
                ]
            ]
        ]


difficultyButton : String -> String -> Difficulty -> Html Msg
difficultyButton title description difficulty =
    button
        [ Html.Events.onClick (NewGame difficulty)
        , Html.Attributes.style "background-color" Style.colors.secondary
        , Html.Attributes.style "color" Style.colors.text
        , Html.Attributes.style "border" ("2px solid " ++ Style.colors.border)
        , Html.Attributes.style "border-radius" "8px"
        , Html.Attributes.style "padding" "15px 25px"
        , Html.Attributes.style "cursor" "pointer"
        , Html.Attributes.style "font-size" "18px"
        , Html.Attributes.style "font-weight" "bold"
        , Html.Attributes.style "transition" "all 0.3s ease"
        , Html.Attributes.style "box-shadow" ("0 2px 4px " ++ Style.colors.shadow)
        ]
        [ div
            [ Html.Attributes.style "margin-bottom" "5px" ]
            [ text title ]
        , div
            [ Html.Attributes.style "font-size" "14px"
            , Html.Attributes.style "font-weight" "normal"
            , Html.Attributes.style "opacity" "0.8"
            ]
            [ text description ]
        ]
