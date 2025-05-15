module LSystem exposing (generate)

import Rules exposing (Rules)
import Sequence exposing (Sequence)


generate : Int -> List ( Char, String ) -> String -> Sequence Char
generate n rules axiom =
    generateHelper n (Rules.fromList rules) (Sequence.fromString axiom)


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


flip : (a -> b -> c) -> b -> a -> c
flip f b a =
    f a b
