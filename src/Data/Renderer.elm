port module Data.Renderer exposing (Msg, Renderer, init, subscriptions, toInfo, update)

import Browser.Events as BE
import Data.Position exposing (Position)
import Data.Timer as Timer exposing (Timer)
import Data.Transformer as Transformer exposing (Instruction(..))
import Json.Encode as JE
import Lib.Sequence as Sequence exposing (Sequence)


type Renderer
    = Renderer State


type alias State =
    { timer : Timer
    , ipfAsInt : Int
    , ipfAsFloat : Float
    , instructions : Sequence Instruction
    , totalInstructions : Int
    , commands : List JE.Value
    }


type alias InitOptions =
    { fps : Int
    , ipf : Int
    , instructions : Sequence Instruction
    }


init : InitOptions -> Renderer
init { fps, ipf, instructions } =
    Renderer
        { timer = Timer.new fps
        , ipfAsInt = ipf
        , ipfAsFloat = toFloat ipf
        , instructions = instructions
        , totalInstructions = 0
        , commands = []
        }


type Msg
    = GotAnimationFrame Float


update : Msg -> Renderer -> ( Renderer, Cmd msg )
update msg (Renderer state) =
    case msg of
        GotAnimationFrame delta ->
            let
                ( timer, ( ( instructions, cmd ), numInstructions ) ) =
                    Timer.step
                        delta
                        (\_ ->
                            let
                                { expectedFps } =
                                    Timer.toInfo state.timer

                                expectedNumInstructions =
                                    ceiling (expectedFps * state.ipfAsFloat * delta * 0.001)

                                n =
                                    max 1 (modBy state.ipfAsInt expectedNumInstructions)
                            in
                            ( render n state.instructions, n )
                        )
                        state.timer

                totalInstructions =
                    state.totalInstructions + numInstructions
            in
            ( Renderer { state | timer = timer, instructions = instructions, totalInstructions = totalInstructions }
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
        values
            |> List.reverse
            |> JE.list identity
            |> drawBatch


port drawBatch : JE.Value -> Cmd msg


subscriptions : (Msg -> msg) -> Renderer -> Sub msg
subscriptions onChange (Renderer { instructions }) =
    if Sequence.isEmpty instructions then
        Sub.none

    else
        BE.onAnimationFrameDelta (onChange << GotAnimationFrame)


type alias Info =
    { expectedFps : Float
    , actualFps : Float
    , cps : Float
    , ips : Float
    , commands : List JE.Value
    }


toInfo : Renderer -> Info
toInfo (Renderer { timer, totalInstructions, commands }) =
    let
        { expectedFps, totalElapsed, actualFps, cps } =
            Timer.toInfo timer
    in
    { expectedFps = expectedFps
    , actualFps = actualFps
    , cps = cps
    , ips =
        if totalElapsed == 0 then
            0

        else
            1000 * toFloat totalInstructions / totalElapsed
    , commands = commands
    }
