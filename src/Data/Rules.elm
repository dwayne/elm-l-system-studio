module Data.Rules exposing (Rules, build, lookup)

import Dict exposing (Dict)
import Lib.Sequence as Sequence exposing (Sequence)
import Set exposing (Set)


type Rules
    = Rules (Dict Char (Sequence Char))


build : List ( Char, String ) -> String -> Rules
build rules axiom =
    let
        singletons =
            buildSingletons rules axiom

        table =
            List.foldl
                (\( ch, replacement ) dict ->
                    Dict.insert ch (Sequence.fromString replacement) dict
                )
                singletons
                rules
    in
    Rules table


buildSingletons : List ( Char, String ) -> String -> Dict Char (Sequence Char)
buildSingletons rules axiom =
    let
        axiomSet =
            toCharSet Set.empty axiom

        ( keySet, valueSet ) =
            List.foldl
                (\( ch, replacement ) ( prevKeySet, prevValueSet ) ->
                    ( Set.insert ch prevKeySet
                    , toCharSet prevValueSet replacement
                    )
                )
                ( Set.empty, axiomSet )
                rules

        singletonsKeySet =
            Set.diff valueSet keySet
    in
    Set.foldl
        (\ch dict ->
            Dict.insert ch (Sequence.singleton ch) dict
        )
        Dict.empty
        singletonsKeySet


toCharSet : Set Char -> String -> Set Char
toCharSet initialChars s =
    String.foldl Set.insert initialChars s


lookup : Char -> Rules -> Sequence Char
lookup ch (Rules table) =
    case Dict.get ch table of
        Just replacement ->
            replacement

        Nothing ->
            Sequence.empty
