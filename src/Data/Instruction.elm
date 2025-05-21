module Data.Instruction exposing (Instruction(..))

import Data.Position exposing (Position)


type Instruction
    = MoveTo Position
    | LineTo
        { position : Position
        , lineWidth : Float
        }
    | Line
        { start : Position
        , end : Position
        , lineWidth : Float
        }


split : Instruction -> Instruction -> ( Instruction, Maybe Instruction )
split a b =
    case ( a, b ) of
        ( MoveTo _, MoveTo _ ) ->
            ( b, Nothing )

        ( MoveTo start, LineTo line ) ->
            ( Line { start = start, end = line.position, lineWidth = line.lineWidth }
            , Nothing
            )

        ( LineTo l1, LineTo l2 ) ->
            ( a
            , Just (Line { start = l1.position, end = l2.position, lineWidth = l2.lineWidth })
            )

        _ ->
            ( a, Just b )
