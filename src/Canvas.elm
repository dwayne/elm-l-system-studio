port module Canvas exposing (Msg, State, init, subscriptions, update, view)

import Browser.Events as BE
import Html as H
import Html.Attributes as HA
import Json.Encode as JE
import LSystem
import Random
import Sequence exposing (Sequence)


type State
    = State
        { sequence : Sequence Char
        , elapsed : Float
        }


init : State
init =
    State
        { sequence = LSystem.generate 100 [ ( 'F', "F+F-F-FF+F+F-F" ) ] "F+F+F+F"
        , elapsed = 0
        }


type alias Line =
    { x1 : Int
    , y1 : Int
    , x2 : Int
    , y2 : Int
    }


lineG : Random.Generator Line
lineG =
    Random.map4 Line intG intG intG intG


intG : Random.Generator Int
intG =
    Random.int 0 500


port drawLine : JE.Value -> Cmd msg


type Msg
    = GotAnimationFrame Float
    | GotLine Line


update : (Msg -> msg) -> Msg -> State -> ( State, Cmd msg )
update onChange msg (State state) =
    case msg of
        GotAnimationFrame delta ->
            let
                elapsed =
                    state.elapsed + delta
            in
            if elapsed >= msPerFrame then
                ( State { state | elapsed = elapsed - msPerFrame }
                , Random.generate (onChange << GotLine) lineG
                )

            else
                ( State { state | elapsed = elapsed }
                , Cmd.none
                )

        GotLine { x1, y1, x2, y2 } ->
            case Sequence.uncons state.sequence of
                Just ( _, restSequence ) ->
                    ( State { state | sequence = restSequence }
                    , drawLine <|
                        JE.object
                            [ ( "x1", JE.int x1 )
                            , ( "y1", JE.int y1 )
                            , ( "x2", JE.int x2 )
                            , ( "y2", JE.int y2 )
                            ]
                    )

                Nothing ->
                    ( State state
                    , Cmd.none
                    )


fps : Float
fps =
    60


msPerFrame : Float
msPerFrame =
    1000 / fps


subscriptions : (Msg -> msg) -> State -> Sub msg
subscriptions onChange (State { sequence }) =
    if Sequence.isEmpty sequence then
        Sub.none

    else
        BE.onAnimationFrameDelta (onChange << GotAnimationFrame)


view : H.Html msg
view =
    H.canvas
        [ HA.id "my-canvas"
        , HA.width 500
        , HA.height 500
        , HA.style "border" "1px solid black"
        ]
        [ H.text "Canvas not supported." ]
