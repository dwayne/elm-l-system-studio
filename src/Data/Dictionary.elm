module Data.Dictionary exposing (Dictionary, Meaning(..), default, find)

import Dict exposing (Dict)


type Dictionary
    = Dictionary (Dict Char Meaning)


type Meaning
    = Move
    | MoveWithoutDrawing
    | TurnLeft
    | TurnRight
    | ReverseDirection
    | Push
    | Pop
    | IncrementLineWidth
    | DecrementLineWidth
    | DrawDot
    | OpenPolygon
    | ClosePolygon
    | MultiplyLineLength
    | DivideLineLength
    | SwapPlusMinus
    | IncrementTurningAngle
    | DecrementTurningAngle


default : Dictionary
default =
    fromDefinitions
        [ ( 'F', Move )
        , ( 'f', MoveWithoutDrawing )
        , ( '+', TurnLeft )
        , ( '-', TurnRight )
        , ( '|', ReverseDirection )
        , ( '[', Push )
        , ( ']', Pop )
        , ( '#', IncrementLineWidth )
        , ( '!', DecrementLineWidth )
        , ( '@', DrawDot )
        , ( '{', OpenPolygon )
        , ( '}', ClosePolygon )
        , ( '>', MultiplyLineLength )
        , ( '<', DivideLineLength )
        , ( '&', SwapPlusMinus )
        , ( '(', DecrementTurningAngle )
        , ( ')', IncrementTurningAngle )
        ]


fromDefinitions : List ( Char, Meaning ) -> Dictionary
fromDefinitions =
    Dictionary << Dict.fromList


find : Char -> Dictionary -> Maybe Meaning
find ch (Dictionary d) =
    Dict.get ch d
