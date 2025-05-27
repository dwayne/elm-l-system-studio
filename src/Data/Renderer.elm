module Data.Renderer exposing (Msg, Renderer, init, subscriptions, update, toInfo)

import Browser.Events as BE
import Data.Instruction exposing (Instruction(..))
import Json.Encode as JE
import Lib.Sequence as Sequence exposing (Sequence)
import Data.Timer as Timer exposing (Timer)


type Renderer
    = Renderer State


type alias State =
    { timer : Timer
    , ipfAsInt : Int
    , ipfAsFloat : Float
    , instructions : Sequence Instruction
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
        , commands = []
        }


type Msg
    = GotAnimationFrame Float


update : (Msg -> msg) -> Msg -> Renderer -> Renderer
update onChange msg (Renderer state) =
    case msg of
        GotAnimationFrame delta ->
            let
                ( timer, newState ) =
                    Timer.step delta
                        (\_ ->
                            encodeCommands delta state
                        )
                        state.timer
            in
            Renderer { newState | timer = timer }


encodeCommands : Float -> State -> State
encodeCommands delta state =
    -- How come we don't get the first command?
    let
        fps =
            Timer.expectedFps state.timer

        n =
            min state.ipfAsInt (ceiling (fps * state.ipfAsFloat * delta * 0.001))

        ( instructions, commands ) =
            encodeCommandsHelper n state.instructions []
    in
    { state | instructions = instructions, commands = List.reverse commands }


encodeCommandsHelper : Int -> Sequence Instruction -> List JE.Value -> ( Sequence Instruction, List JE.Value )
encodeCommandsHelper n instructions commands =
    if n > 0 then
        case Sequence.uncons instructions of
            Just ( instruction, restInstructions ) ->
                encodeCommandsHelper
                    (n - 1)
                    restInstructions
                    (encode instruction :: commands)
                    |> Debug.log (Debug.toString instruction)

            Nothing ->
                ( instructions, commands )

    else
        ( instructions, commands )


encode : Instruction -> JE.Value
encode instruction =
    case instruction of
        MoveTo { x, y } ->
            JE.object
                [ ( "function", JE.string "moveTo" )
                , ( "x", JE.float x )
                , ( "y", JE.float y )
                ]

        LineTo { position, lineWidth } ->
            JE.object
                [ ( "function", JE.string "lineTo" )
                , ( "x", JE.float position.x )
                , ( "y", JE.float position.y )
                , ( "lineWidth", JE.float lineWidth )
                ]

        _ ->
            JE.int 0


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
    , commands : List JE.Value
    }


toInfo : Renderer -> Info
toInfo (Renderer { timer, commands }) =
    { expectedFps = Timer.expectedFps timer
    , actualFps = Timer.actualFps timer
    , cps = Timer.cps timer
    , commands = commands
    }
