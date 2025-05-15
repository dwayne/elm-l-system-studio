module Rules exposing (Rules, fromList, lookup)

import Dict exposing (Dict)
import Sequence exposing (Sequence)


type Rules
    = Rules (Dict Char (Sequence Char))


fromList : List ( Char, String ) -> Rules
fromList =
    Rules << Dict.fromList << List.map (Tuple.mapSecond Sequence.fromString)


lookup : Char -> Rules -> Sequence Char
lookup ch (Rules table) =
    Dict.get ch table
        |> Maybe.withDefault (Sequence.singleton ch)
