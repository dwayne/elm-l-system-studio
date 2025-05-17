module Lib.Sequence exposing
    ( Sequence
    , concat
    , concatMap
    , empty
    , fromString
    , length
    , singleton
    , toList
    , uncons
    )


type Sequence a
    = Empty
    | Cons a (Sequence a)
    | Thunk (() -> Sequence a)



-- CREATE


empty : Sequence a
empty =
    Empty


singleton : a -> Sequence a
singleton x =
    Cons x Empty


fromString : String -> Sequence Char
fromString s =
    Thunk (\_ -> String.foldr Cons Empty s)



-- COMBINE


concat : Sequence a -> Sequence a -> Sequence a
concat a b =
    case a of
        Empty ->
            b

        Cons head tail ->
            Cons head (concat tail b)

        Thunk t ->
            Thunk (\_ -> concat (t ()) b)


concatMap : (a -> Sequence b) -> Sequence a -> Sequence b
concatMap f s =
    case s of
        Empty ->
            Empty

        Cons head tail ->
            concat
                (f head)
                (concatMap f tail)

        Thunk t ->
            Thunk (\_ -> concatMap f (t ()))



-- QUERY


length : Sequence a -> Int
length =
    lengthHelper 0


lengthHelper : Int -> Sequence a -> Int
lengthHelper n s =
    case s of
        Empty ->
            n

        Cons _ tail ->
            lengthHelper (n + 1) tail

        Thunk t ->
            lengthHelper n (t ())



-- CONVERT


uncons : Sequence a -> Maybe ( a, Sequence a )
uncons s =
    case s of
        Empty ->
            Nothing

        Cons head tail ->
            Just ( head, tail )

        Thunk t ->
            uncons (t ())


toList : Sequence a -> List a
toList s =
    case s of
        Empty ->
            []

        Cons head tail ->
            head :: toList tail

        Thunk t ->
            toList (t ())
