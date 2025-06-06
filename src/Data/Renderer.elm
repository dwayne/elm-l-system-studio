port module Data.Renderer exposing (Msg, Renderer, init, subscriptions, toStats, update)

import Browser.Events as BE
import Data.Transformer as Transformer exposing (Instruction(..))
import Json.Encode as JE
import Lib.Sequence as Sequence exposing (Sequence)
import Lib.Timer as Timer exposing (Timer)


type Renderer
    = Renderer State


type alias State =
    { timer : Timer
    , ipfAsInt : Int
    , ipfAsFloat : Float
    , instructions : Sequence Instruction
    , totalInstructionsRendered : Int
    }


type alias InitOptions =
    { fps : Int
    , ipf : Int -- instructions per frame
    , instructions : Sequence Instruction
    }


init : InitOptions -> Renderer
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


update : Msg -> Renderer -> ( Renderer, Cmd msg )
update msg (Renderer state) =
    case msg of
        GotAnimationFrame delta ->
            let
                ( timer, ( ( restInstructions, cmd ), numInstructionsRendered ) ) =
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
                            ( render actualN state.instructions, actualN )
                        )
                        state.timer

                totalInstructionsRendered =
                    state.totalInstructionsRendered + numInstructionsRendered
            in
            ( Renderer
                { state
                    | timer = timer
                    , instructions = restInstructions
                    , totalInstructionsRendered = totalInstructionsRendered
                }
            , cmd
            )


render : Int -> Sequence Instruction -> ( Sequence Instruction, Cmd msg )
render =
    renderHelper []


renderHelper : List JE.Value -> Int -> Sequence Instruction -> ( Sequence Instruction, Cmd msg )
renderHelper values atMost instructions =
    if atMost > 0 then
        case Sequence.uncons instructions of
            Just ( instruction, restInstructions ) ->
                renderHelper
                    (Transformer.encode instruction :: values)
                    (atMost - 1)
                    restInstructions

            Nothing ->
                ( instructions
                , toCmd values
                )

    else
        ( instructions
        , toCmd values
        )


toCmd : List JE.Value -> Cmd msg
toCmd values =
    if values == [] then
        Cmd.none

    else
        drawBatch (JE.list identity (List.reverse values))


port drawBatch : JE.Value -> Cmd msg


subscriptions : (Msg -> msg) -> Renderer -> Sub msg
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


toStats : Renderer -> Stats
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
