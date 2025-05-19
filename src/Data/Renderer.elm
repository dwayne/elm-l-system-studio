port module Data.Renderer exposing (Msg, Renderer, init, subscriptions, update)

-- TODO: Extract ports.

import Browser.Events as BE
import Data.Translator exposing (Instruction(..))
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


port moveTo : JE.Value -> Cmd msg


port lineTo : JE.Value -> Cmd msg


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
                in
                case Sequence.uncons state.instructions of
                    Just ( instruction, restInstructions ) ->
                        ( Renderer { state | elapsed = newElapsed, instructions = restInstructions }
                          -- TODO: Extract into a function
                        , case instruction of
                            MoveTo ( x, y ) ->
                                moveTo <|
                                    JE.object
                                        [ ( "x", JE.float x )
                                        , ( "y", JE.float y )
                                        ]

                            LineTo { position, lineWidth } ->
                                let
                                    ( x, y ) =
                                        position
                                in
                                lineTo <|
                                    JE.object
                                        [ ( "x", JE.float x )
                                        , ( "y", JE.float y )
                                        , ( "lineWidth", JE.float lineWidth )
                                        ]
                        )

                    Nothing ->
                        ( Renderer state
                        , Cmd.none
                        )

            else
                ( Renderer { state | elapsed = elapsed }
                , Cmd.none
                )


subscriptions : (Msg -> msg) -> Renderer -> Sub msg
subscriptions onChange (Renderer { instructions }) =
    if Sequence.isEmpty instructions then
        Sub.none

    else
        BE.onAnimationFrameDelta (onChange << GotAnimationFrame)
