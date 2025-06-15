module Lib.Maybe exposing (apply)


apply : Maybe a -> Maybe (a -> b) -> Maybe b
apply ma mf =
    case ( ma, mf ) of
        ( Just a, Just f ) ->
            Just (f a)

        _ ->
            Nothing
