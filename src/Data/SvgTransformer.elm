module Data.SvgTransformer exposing
    ( Coords
    , Instruction(..)
    , TransformOptions
    , encode
    , transform
    )

import Data.Position exposing (Position)
import Data.SvgTranslator as Translator
import Json.Encode as JE
import Lib.Sequence as Sequence exposing (Sequence)
import Svg as S
import Svg.Attributes as SA


type alias TransformOptions =
    { windowPosition : Position
    , windowSize : Float
    , canvasSize : Int
    }


transform : TransformOptions -> Sequence Translator.Instruction -> Sequence Instruction
transform { windowPosition, windowSize, canvasSize } instructions =
    let
        l =
            toFloat canvasSize

        config =
            { x0 = windowPosition.x
            , y0 = windowPosition.y
            , s = windowSize
            , l = l
            , ls = l / windowSize
            }

        toCoords =
            transformPosition config
    in
    Sequence.map (transformInstruction toCoords) instructions


type alias Config =
    { x0 : Float
    , y0 : Float
    , s : Float
    , l : Float
    , ls : Float
    }


type Instruction
    = Line
        { start : Coords
        , end : Coords
        , lineWidth : Float
        }


type alias Coords =
    { x : Int
    , y : Int
    }


transformInstruction : (Position -> Coords) -> Translator.Instruction -> Instruction
transformInstruction toCoords instruction =
    case instruction of
        Translator.Line { start, end, lineWidth } ->
            Line
                { start = toCoords start
                , end = toCoords end
                , lineWidth = lineWidth
                }


transformPosition : Config -> Position -> Coords
transformPosition { x0, y0, s, l, ls } position =
    let
        xw =
            position.x

        yw =
            position.y
    in
    { x = round ((xw - x0) * ls)
    , y = round (l - (yw - y0) * ls)
    }


encode : Instruction -> S.Svg msg
encode instruction =
    case instruction of
        Line { start, end, lineWidth } ->
            let
                x1 =
                    String.fromInt start.x

                y1 =
                    String.fromInt start.y

                x2 =
                    String.fromInt end.x

                y2 =
                    String.fromInt end.y
            in
            S.line
                [ SA.x1 x1
                , SA.y1 y1
                , SA.x2 x2
                , SA.y2 y2
                , SA.stroke "black"
                , SA.strokeWidth (String.fromFloat lineWidth)
                ]
                []
