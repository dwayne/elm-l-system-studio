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
    | LineTo
        { position : Coords
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

        Translator.LineTo { position, lineWidth } ->
            LineTo
                { position = toCoords position
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
                [ ( "function", JE.string "moveTo" )
                , ( "x", JE.int x )
                , ( "y", JE.int y )
                ]

        LineTo { position, lineWidth } ->
            let
                { x, y } =
                    position
            in
            JE.object
                [ ( "function", JE.string "lineTo" )
                , ( "x", JE.int x )
                , ( "y", JE.int y )
                , ( "lineWidth", JE.float lineWidth )
                ]
