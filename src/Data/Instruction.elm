module Data.Instruction exposing (Instruction(..), encode, endingPosition)

import Data.Position exposing (Position)
import Json.Encode as JE


type Instruction
    = MoveTo Position
    | LineTo
        { position : Position
        , lineWidth : Float
        }


endingPosition : Instruction -> Position
endingPosition instruction =
    case instruction of
        MoveTo position ->
            position

        LineTo { position } ->
            position


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
