module Data.SvgRenderer2 exposing (Msg, Renderer, init, subscriptions, update, view)

import Browser.Events as BE
import Data.SvgTransformer as Transformer exposing (Instruction(..))
import Html as H
import Lib.Sequence as Sequence exposing (Sequence)
import Svg as S
import Svg.Attributes as SA
import Svg.Keyed as SK


type Renderer msg
    = Renderer (State msg)


type alias State msg =
    { id : Int
    , instructions : Sequence Instruction
    , svgs : List ( String, S.Svg msg )
    }


init : Sequence Instruction -> Renderer msg
init instructions =
    Renderer
        { id = 0
        , instructions = instructions
        , svgs = []
        }


type Msg
    = GotAnimationFrame Float


update : Msg -> Renderer msg -> Renderer msg
update msg (Renderer state) =
    case msg of
        GotAnimationFrame delta ->
            case Sequence.uncons state.instructions of
                Just ( instruction, restInstructions ) ->
                    Renderer
                        { state
                            | id = state.id + 1
                            , instructions = restInstructions
                            , svgs = ( String.fromInt state.id, Transformer.encode instruction ) :: state.svgs
                        }

                Nothing ->
                    Renderer state


subscriptions : (Msg -> msg) -> Renderer msg -> Sub msg
subscriptions onChange (Renderer { instructions }) =
    if Sequence.isEmpty instructions then
        Sub.none

    else
        BE.onAnimationFrameDelta (onChange << GotAnimationFrame)


type alias ViewOptions msg =
    { width : Int
    , height : Int
    , renderer : Renderer msg
    }


view : ViewOptions msg -> H.Html msg
view { width, height, renderer } =
    let
        svgs =
            case renderer of
                Renderer state ->
                    state.svgs

        widthAsString =
            String.fromInt width

        heightAsString =
            String.fromInt height
    in
    S.svg
        [ SA.class "canvas"
        , SA.width widthAsString
        , SA.height heightAsString
        , SA.viewBox ("0 0 " ++ widthAsString ++ " " ++ heightAsString)
        ]
        [ SK.node "g" [] svgs
        ]
