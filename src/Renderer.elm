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


type State
    = State
        { sequence : Sequence Char
        , lines : List Line
        }


init : State
init =
    State
        { sequence = LSystem.generate 100 [ ( 'F', "F+F-F-FF+F+F-F" ) ] "F+F+F+F"
        , lines = []
        }


type Msg
    = GotAnimationFrame
    | GotLines (List Line)


update : (Msg -> msg) -> Msg -> State -> ( State, Cmd msg )
update onChange msg (State state) =
    case msg of
        GotAnimationFrame ->
            ( State state
            , Random.generate (onChange << GotLines) (Line.lines 100)
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


subscriptions : (Msg -> msg) -> State -> Sub msg
subscriptions onChange (State { sequence }) =
    if Sequence.isEmpty sequence then
        Sub.none

    else
        BE.onAnimationFrameDelta (onChange << always GotAnimationFrame)


view : State -> H.Html msg
view (State { lines }) =
    Canvas.view
        { width = 500
        , height = 500
        , lines = lines
        , attrs = [ HA.style "border" "1px solid black" ]
        }
