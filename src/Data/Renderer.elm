module Data.Renderer exposing
    ( InitOptions
    , Msg
    , Renderer
    , init
    , subscriptions
    , toStats
    , update
    )

import Browser.Events as BE
import Json.Encode as JE
import Lib.Sequence as Sequence exposing (Sequence)
import Lib.Timer as Timer exposing (Timer)


type Renderer instruction
    = Renderer (State instruction)


type alias State instruction =
    { timer : Timer
    , ipfAsInt : Int
    , ipfAsFloat : Float
    , instructions : Sequence instruction
    , totalInstructionsRendered : Int
    }


type alias InitOptions instruction =
    { fps : Int
    , ipf : Int -- instructions per frame
    , instructions : Sequence instruction
    }


init : InitOptions instruction -> Renderer instruction
init { fps, ipf, instructions } =
    let
        ipfAsInt =
            max 1 ipf
    in
    Renderer
        { timer = Timer.new fps
        , ipfAsInt = ipfAsInt
        , ipfAsFloat = toFloat ipfAsInt
        , instructions = instructions
        , totalInstructionsRendered = 0
        }


type Msg
    = GotAnimationFrame Float


update : (instruction -> JE.Value) -> Msg -> Renderer instruction -> ( Renderer instruction, JE.Value )
update encode msg renderer =
    case msg of
        GotAnimationFrame delta ->
            handleAnimationFrame delta encode renderer


handleAnimationFrame : Float -> (instruction -> JE.Value) -> Renderer instruction -> ( Renderer instruction, JE.Value )
handleAnimationFrame delta encode (Renderer state) =
    Tuple.mapFirst Renderer (handleAnimationFrameHelper delta encode state)


handleAnimationFrameHelper : Float -> (instruction -> JE.Value) -> State instruction -> ( State instruction, JE.Value )
handleAnimationFrameHelper delta encode state =
    let
        ( timer, ( ( restInstructions, values ), numInstructionsRendered ) ) =
            Timer.step
                delta
                (\_ ->
                    let
                        expectedFps =
                            Timer.getExpectedFps state.timer

                        suggestedN =
                            ceiling (expectedFps * state.ipfAsFloat * delta * 0.001)

                        actualN =
                            max 1 (modBy state.ipfAsInt suggestedN)
                    in
                    ( render actualN encode state.instructions, actualN )
                )
                state.timer

        totalInstructionsRendered =
            state.totalInstructionsRendered + numInstructionsRendered
    in
    ( { state
        | timer = timer
        , instructions = restInstructions
        , totalInstructionsRendered = totalInstructionsRendered
      }
    , JE.list identity (List.reverse values)
    )


render : Int -> (instruction -> JE.Value) -> Sequence instruction -> ( Sequence instruction, List JE.Value )
render =
    renderHelper []


renderHelper : List JE.Value -> Int -> (instruction -> JE.Value) -> Sequence instruction -> ( Sequence instruction, List JE.Value )
renderHelper values atMost encode instructions =
    if atMost > 0 then
        case Sequence.uncons instructions of
            Just ( instruction, restInstructions ) ->
                renderHelper
                    (encode instruction :: values)
                    (atMost - 1)
                    encode
                    restInstructions

            Nothing ->
                ( instructions
                , values
                )

    else
        ( instructions
        , values
        )


subscriptions : (Msg -> msg) -> Renderer instruction -> Sub msg
subscriptions onChange (Renderer { instructions }) =
    if Sequence.isEmpty instructions then
        Sub.none

    else
        BE.onAnimationFrameDelta (onChange << GotAnimationFrame)


type alias Stats =
    { expectedFps : Float
    , actualFps : Float
    , cps : Float
    , expectedIps : Float
    , actualIps : Float
    }


toStats : Renderer instruction -> Stats
toStats (Renderer { timer, ipfAsFloat, totalInstructionsRendered }) =
    let
        { expectedFps, totalElapsed, actualFps, cps } =
            Timer.toStats timer
    in
    { expectedFps = expectedFps
    , actualFps = actualFps
    , cps = cps
    , expectedIps = ipfAsFloat * expectedFps
    , actualIps =
        if totalElapsed == 0 then
            0

        else
            1000 * toFloat totalInstructionsRendered / totalElapsed
    }
