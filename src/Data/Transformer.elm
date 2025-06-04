module Data.Transformer exposing
    ( Coords
    , Instruction(..)
    , TransformOptions
    , encode
    , transform
    )

import Data.Position exposing (Position)
import Data.Translator as Translator
import Json.Encode as JE
import Lib.Sequence as Sequence exposing (Sequence)


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
    = MoveTo Coords
    | Line
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
        Translator.MoveTo position ->
            MoveTo (toCoords position)

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


encode : Instruction -> JE.Value
encode instruction =
    case instruction of
        MoveTo { x, y } ->
            JE.object
                [ ( "tag", JE.string "moveTo" )
                , ( "x", JE.int x )
                , ( "y", JE.int y )
                ]

        Line { start, end, lineWidth } ->
            JE.object
                [ ( "tag", JE.string "line" )
                , ( "x1", JE.int start.x )
                , ( "y1", JE.int start.y )
                , ( "x2", JE.int end.x )
                , ( "y2", JE.int end.y )
                ]
