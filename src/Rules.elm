module Rules exposing (Rules, build, lookup)

import Dict exposing (Dict)
import Sequence exposing (Sequence)
import Set


type Rules
    = Rules (Dict Char (Sequence Char))


build : List ( Char, String ) -> String -> Rules
build rules axiom =
    let
        identity =
            buildIdentity rules axiom
    in
    rules
        |> List.map (Tuple.mapSecond Sequence.fromString)
        |> Dict.fromList
        |> Dict.union identity
        |> Rules


buildIdentity : List ( Char, String ) -> String -> Dict Char (Sequence Char)
buildIdentity rules axiom =
    let
        axiomSet =
            axiom
                |> String.toList
                |> Set.fromList

        ( keySet, valueSet ) =
            rules
                |> List.foldl
                    (\( ch, replacement ) ( prevKeySet, prevValueSet ) ->
                        ( Set.insert ch prevKeySet
                        , replacement
                            |> String.toList
                            |> Set.fromList
                            |> Set.union prevValueSet
                        )
                    )
                    ( Set.empty, Set.empty )

        identityKeySet =
            Set.diff (Set.union axiomSet valueSet) keySet
    in
    identityKeySet
        |> Set.foldl
            (\ch ->
                Dict.insert ch (Sequence.singleton ch)
            )
            Dict.empty


lookup : Char -> Rules -> Sequence Char
lookup ch (Rules table) =
    Dict.get ch table
        |> Maybe.withDefault Sequence.empty
