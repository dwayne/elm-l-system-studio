port module Data.Renderer exposing (Msg, Renderer, init, subscriptions, update)

import Browser.Events as BE
import Data.Instruction exposing (Instruction(..))
import Json.Encode as JE
import Lib.Sequence as Sequence exposing (Sequence)


type Renderer
    = Renderer
        { instructions : Sequence Instruction
        , elapsed : Float
        }


fps : Float
fps =
    60


msPerFrame : Float
msPerFrame =
    1000 / fps


init : Sequence Instruction -> Renderer
init instructions =
    Renderer
        { instructions = instructions
        , elapsed = 0
        }


type Msg
    = GotAnimationFrame Float


update : (Msg -> msg) -> Msg -> Renderer -> ( Renderer, Cmd msg )
update onChange msg (Renderer state) =
    case msg of
        GotAnimationFrame delta ->
            let
                elapsed =
                    state.elapsed + delta
            in
            if elapsed >= msPerFrame then
                let
                    newElapsed =
                        elapsed - msPerFrame

                    ( instructions, cmd ) =
                        render 100 state.instructions
                in
                ( Renderer { state | elapsed = newElapsed, instructions = instructions }
                , cmd
                )

            else
                ( Renderer { state | elapsed = elapsed }
                , Cmd.none
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
                    (encode instruction :: values)
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


port drawBatch : JE.Value -> Cmd msg


subscriptions : (Msg -> msg) -> Renderer -> Sub msg
subscriptions onChange (Renderer { instructions }) =
    if Sequence.isEmpty instructions then
        Sub.none

    else
        BE.onAnimationFrameDelta (onChange << GotAnimationFrame)
