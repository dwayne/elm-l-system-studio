module Data.SvgRenderer exposing (Msg, Renderer, init, subscriptions, toInfo, update, view)

import Browser.Events as BE
import Data.SvgTransformer as Transformer exposing (Instruction(..))
import Data.Timer as Timer exposing (Timer)
import Html as H
import Lib.Sequence as Sequence exposing (Sequence)
import Svg as S
import Svg.Attributes as SA
import Svg.Keyed as SK


type Renderer msg
    = Renderer (State msg)


type alias State msg =
    { timer : Timer
    , ipfAsInt : Int
    , ipfAsFloat : Float
    , instructions : Sequence Instruction
    , totalInstructions : Int
    , id : Int
    , svgs : List ( String, S.Svg msg )
    }


type alias InitOptions =
    { fps : Int
    , ipf : Int
    , instructions : Sequence Instruction
    }


init : InitOptions -> Renderer msg
init { fps, ipf, instructions } =
    Renderer
        { timer = Timer.new fps
        , ipfAsInt = ipf
        , ipfAsFloat = toFloat ipf
        , instructions = instructions
        , totalInstructions = 0
        , id = 0
        , svgs = []
        }


type Msg
    = GotAnimationFrame Float


update : Msg -> Renderer msg -> Renderer msg
update msg (Renderer state) =
    case msg of
        GotAnimationFrame delta ->
            let
                ( timer, ( renderOutput, numInstructions ) ) =
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
                            ( render
                                { n = n
                                , instructions = state.instructions
                                , id = state.id
                                , svgs = state.svgs
                                }
                            , n
                            )
                        )
                        state.timer

                totalInstructions =
                    state.totalInstructions + numInstructions
            in
            Renderer
                { state
                    | timer = timer
                    , instructions = renderOutput.instructions
                    , totalInstructions = totalInstructions
                    , id = renderOutput.id
                    , svgs = renderOutput.svgs
                }


type alias RenderOptions msg =
    { n : Int
    , instructions : Sequence Instruction
    , id : Int
    , svgs : List ( String, S.Svg msg )
    }


type alias RenderOutput msg =
    { instructions : Sequence Instruction
    , id : Int
    , svgs : List ( String, S.Svg msg )
    }


render : RenderOptions msg -> RenderOutput msg
render options =
    if options.n > 0 then
        case Sequence.uncons options.instructions of
            Just ( instruction, restInstructions ) ->
                render
                    { options
                        | n = options.n - 1
                        , instructions = restInstructions
                        , id = options.id + 1
                        , svgs =
                            ( String.fromInt options.id, Transformer.encode instruction ) :: options.svgs
                    }

            Nothing ->
                { instructions = options.instructions
                , id = options.id
                , svgs = options.svgs
                }

    else
        { instructions = options.instructions
        , id = options.id
        , svgs = options.svgs
        }


subscriptions : (Msg -> msg) -> Renderer msg -> Sub msg
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
    }


toInfo : Renderer msg -> Info
toInfo (Renderer { timer, totalInstructions }) =
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
    }


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
