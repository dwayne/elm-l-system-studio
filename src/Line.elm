module Line exposing (Line, lines, toValue)

import Json.Encode as JE
import Random


type alias Line =
    { x1 : Int
    , y1 : Int
    , x2 : Int
    , y2 : Int
    }


lines : Random.Generator (List Line)
lines =
    Random.list 1000 line


line : Random.Generator Line
line =
    Random.map4 Line int int int int


int : Random.Generator Int
int =
    Random.int 0 500


toValue : Line -> JE.Value
toValue { x1, y1, x2, y2 } =
    JE.object
        [ ( "x1", JE.int x1 )
        , ( "y1", JE.int y1 )
        , ( "x2", JE.int x2 )
        , ( "y2", JE.int y2 )
        ]
