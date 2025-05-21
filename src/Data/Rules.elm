module Data.Rules exposing (Rules, build, lookup)

import Dict exposing (Dict)
import Lib.Sequence as Sequence exposing (Sequence)
import Set exposing (Set)


type Rules
    = Rules (Dict Char (Sequence Char))


build : List ( Char, String ) -> String -> Rules
build rules axiom =
    let
        identity =
            buildIdentity rules axiom

        dict =
            List.foldl
                (\( ch, replacement ) ->
                    Dict.insert ch (Sequence.fromString replacement)
                )
                identity
                rules
    in
    Rules dict


buildIdentity : List ( Char, String ) -> String -> Dict Char (Sequence Char)
buildIdentity rules axiom =
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

        identityKeySet =
            Set.diff valueSet keySet
    in
    Set.foldl
        (\ch ->
            Dict.insert ch (Sequence.singleton ch)
        )
        Dict.empty
        identityKeySet


toCharSet : Set Char -> String -> Set Char
toCharSet =
    String.foldl Set.insert


lookup : Char -> Rules -> Sequence Char
lookup ch (Rules table) =
    case Dict.get ch table of
        Just replacement ->
            replacement

        Nothing ->
            Sequence.empty
