module Data.LSystem exposing (generate)

import Data.Rules as Rules exposing (Rules)
import Lib.Function exposing (flip)
import Lib.Sequence as Sequence exposing (Sequence)


generate : Int -> List ( Char, String ) -> String -> Sequence Char
generate n rules axiom =
    generateHelper n (Rules.build rules axiom) (Sequence.fromString axiom)


generateHelper : Int -> Rules -> Sequence Char -> Sequence Char
generateHelper n rules current =
    if n <= 0 then
        current

    else
        let
            next =
                Sequence.concatMap (flip Rules.lookup rules) current
        in
        generateHelper (n - 1) rules next
