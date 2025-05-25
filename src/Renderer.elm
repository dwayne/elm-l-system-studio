module Renderer exposing (Msg, State, init, subscriptions, update, view)

import Browser.Events as BE
import Canvas
import Html as H
import Html.Attributes as HA
import Html.Keyed as HK
import Json.Encode as JE
import LSystem
import Line exposing (Line)
import Random
import Sequence exposing (Sequence)
import Timer exposing (Timer)


type State
    = State
        { sequence : Sequence Char
        , lines : List Line
        , timer : Timer
        }


init : State
init =
    State
        { sequence = LSystem.generate 100 [ ( 'F', "F+F-F-FF+F+F-F" ) ] "F+F+F+F"
        , lines = []
        , timer = Timer.new fps
        }


fps : Int
fps =
    --
    -- Frames per second
    --
    60


lpf : Int
lpf =
    --
    -- Lines per frame
    --
    100


type Msg
    = GotAnimationFrame Float
    | GotLines (List Line)


update : (Msg -> msg) -> Msg -> State -> ( State, Cmd msg )
update onChange msg (State state) =
    case msg of
        GotAnimationFrame delta ->
            let
                ( timer, cmd ) =
                    Timer.step
                        delta
                        (\_ ->
                            Random.generate (onChange << GotLines) (Line.lines (numLines fps lpf delta))
                        )
                        state.timer
            in
            ( State { state | timer = timer }
            , cmd
            )

        GotLines lines ->
            case Sequence.uncons state.sequence of
                Just ( _, restSequence ) ->
                    ( State { state | sequence = restSequence, lines = lines }
                    , Cmd.none
                    )

                Nothing ->
                    ( State state
                    , Cmd.none
                    )


numLines : Int -> Int -> Float -> Int
numLines fpsInt lpfInt delta =
    let
        fpsFloat =
            toFloat fpsInt

        lpfFloat =
            toFloat lpfInt
    in
    min lpfInt (ceiling (fpsFloat * lpfFloat * delta * 0.001))


subscriptions : (Msg -> msg) -> State -> Sub msg
subscriptions onChange (State { sequence }) =
    if Sequence.isEmpty sequence then
        Sub.none

    else
        BE.onAnimationFrameDelta (onChange << GotAnimationFrame)


view : State -> H.Html msg
view (State { lines, timer }) =
    H.div []
        [ Canvas.view
            { width = 500
            , height = 500
            , lines = lines
            , attrs = [ HA.style "border" "1px solid black" ]
            }
        , H.p [] [ H.text <| "Actual FPS = " ++ String.fromFloat (Timer.actualFps timer) ]
        ]
