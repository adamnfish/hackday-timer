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
    | AddTime
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

        AddTime ->
            let
                newState =
                    if model.state == Finished then
                        Paused
                    else
                        model.state
            in
            ( { model | secondsRemaining = model.secondsRemaining + 10, state = newState }, Cmd.none )

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
    let
        ( toggleLabel, toggleMsg, toggleEnabled ) =
            case model.state of
                NotStarted ->
                    ( "Start", Just Start, True )

                Running ->
                    ( "Pause", Just Pause, True )

                Paused ->
                    ( "Resume", Just Resume, True )

                Finished ->
                    ( "Start", Just Start, False )

        addTimeEnabled =
            model.state /= NotStarted
    in
    [ toggleButton toggleLabel toggleMsg toggleEnabled
    , addTimeButton addTimeEnabled
    , resetButtonWithState (model.state /= NotStarted)
    ]


baseStyles : Bool -> List (Html.Attribute msg)
baseStyles enabled =
    [ style "padding" "6px 12px"
    , style "font-size" "12px"
    , style "border" "1px solid #ddd"
    , style "border-radius" "4px"
    , style "background-color" "#fff"
    , style "color" (if enabled then "#666" else "#ccc")
    , style "cursor" (if enabled then "pointer" else "not-allowed")
    , style "font-weight" "400"
    , style "transition" "all 0.2s"
    , style "box-shadow" "0 1px 2px rgba(0,0,0,0.05)"
    , style "opacity" (if enabled then "0.7" else "0.4")
    , style "min-width" "70px"
    ]


toggleButton : String -> Maybe Msg -> Bool -> Html Msg
toggleButton label maybeMsg enabled =
    let
        clickHandler =
            case ( enabled, maybeMsg ) of
                ( True, Just msg ) ->
                    [ onClick msg ]

                _ ->
                    []
    in
    button
        (baseStyles enabled ++ clickHandler)
        [ text label ]


addTimeButton : Bool -> Html Msg
addTimeButton enabled =
    let
        clickHandler =
            if enabled then
                [ onClick AddTime ]
            else
                []
    in
    button
        (baseStyles enabled ++ clickHandler)
        [ text "+10s" ]


resetButtonWithState : Bool -> Html Msg
resetButtonWithState enabled =
    let
        clickHandler =
            if enabled then
                [ onClickWithModifier (\modifierPressed -> Reset modifierPressed) ]
            else
                []
    in
    button
        (baseStyles enabled ++ clickHandler)
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


