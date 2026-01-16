port module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h1, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick, custom)
import Json.Decode as Decode
import Time


port playSound : () -> Cmd msg


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type TimerState
    = NotStarted
    | Running
    | Paused
    | Finished


type alias Model =
    { secondsRemaining : Int
    , state : TimerState
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { secondsRemaining = 120
      , state = NotStarted
      }
    , Cmd.none
    )


type Msg
    = Start
    | Pause
    | Resume
    | Reset Bool
    | Tick


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Start ->
            ( { model | state = Running }, Cmd.none )

        Pause ->
            ( { model | state = Paused }, Cmd.none )

        Resume ->
            ( { model | state = Running }, Cmd.none )

        Reset isDebugMode ->
            let
                resetSeconds =
                    if isDebugMode then
                        10
                    else
                        120
            in
            ( { secondsRemaining = resetSeconds, state = NotStarted }, Cmd.none )

        Tick ->
            if model.state == Running then
                let
                    newSeconds =
                        model.secondsRemaining - 1

                    newState =
                        if newSeconds <= 0 then
                            Finished

                        else
                            Running

                    soundCmd =
                        if newSeconds <= 0 then
                            playSound ()
                        else
                            Cmd.none
                in
                ( { model | secondsRemaining = max 0 newSeconds, state = newState }, soundCmd )

            else
                ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.state of
        Running ->
            Time.every 1000 (\_ -> Tick)

        _ ->
            Sub.none


view : Model -> Html Msg
view model =
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "align-items" "center"
        , style "justify-content" "center"
        , style "height" "100vh"
        , style "font-family" "Arial, sans-serif"
        , style "background-color" "#f5f5f5"
        ]
        [ h1
            [ style "font-size" "clamp(180px, 40vw, 800px)"
            , style "margin" "0"
            , style "padding" "20px"
            , style "color" (timerColor model.state)
            , style "font-weight" "200"
            , style "font-variant-numeric" "tabular-nums"
            , style "line-height" "1"
            , style "letter-spacing" "0.02em"
            ]
            [ text (formatTime model.secondsRemaining) ]
        , div
            [ style "position" "fixed"
            , style "bottom" "20px"
            , style "display" "flex"
            , style "gap" "8px"
            ]
            (viewButtons model)
        ]


timerColor : TimerState -> String
timerColor state =
    case state of
        NotStarted ->
            "#333"

        Running ->
            "#5A9FD4"

        Paused ->
            "#FFA500"

        Finished ->
            "#E74C3C"


formatTime : Int -> String
formatTime totalSeconds =
    let
        minutes =
            totalSeconds // 60

        seconds =
            modBy 60 totalSeconds

        pad n =
            if n < 10 then
                "0" ++ String.fromInt n

            else
                String.fromInt n
    in
    String.fromInt minutes ++ ":" ++ pad seconds


viewButtons : Model -> List (Html Msg)
viewButtons model =
    case model.state of
        NotStarted ->
            [ styledButton Start "Start" "#5A9FD4" ]

        Running ->
            [ styledButton Pause "Pause" "#FFA500"
            , resetButton
            ]

        Paused ->
            [ styledButton Resume "Resume" "#5A9FD4"
            , resetButton
            ]

        Finished ->
            [ resetButton ]


resetButton : Html Msg
resetButton =
    button
        [ onClickWithModifier (\modifierPressed -> Reset modifierPressed)
        , style "padding" "6px 12px"
        , style "font-size" "12px"
        , style "border" "1px solid #ddd"
        , style "border-radius" "4px"
        , style "background-color" "#fff"
        , style "color" "#666"
        , style "cursor" "pointer"
        , style "font-weight" "400"
        , style "transition" "all 0.2s"
        , style "box-shadow" "0 1px 2px rgba(0,0,0,0.05)"
        , style "opacity" "0.7"
        ]
        [ text "Reset" ]


onClickWithModifier : (Bool -> msg) -> Html.Attribute msg
onClickWithModifier toMsg =
    let
        modifierDecoder =
            Decode.oneOf
                [ Decode.field "metaKey" Decode.bool  -- Command on Mac
                , Decode.field "ctrlKey" Decode.bool  -- Ctrl on Windows/Linux
                ]

        decoder =
            Decode.map
                (\isModified ->
                    { message = toMsg isModified
                    , stopPropagation = False
                    , preventDefault = False
                    }
                )
                modifierDecoder
    in
    custom "click" decoder


styledButton : Msg -> String -> String -> Html Msg
styledButton msg label color =
    button
        [ onClick msg
        , style "padding" "6px 12px"
        , style "font-size" "12px"
        , style "border" "1px solid #ddd"
        , style "border-radius" "4px"
        , style "background-color" "#fff"
        , style "color" "#666"
        , style "cursor" "pointer"
        , style "font-weight" "400"
        , style "transition" "all 0.2s"
        , style "box-shadow" "0 1px 2px rgba(0,0,0,0.05)"
        , style "opacity" "0.7"
        ]
        [ text label ]

