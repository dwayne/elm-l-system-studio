module Lib.Maybe exposing (apply, join)


apply : Maybe a -> Maybe (a -> b) -> Maybe b
apply ma mf =
    case ( ma, mf ) of
        ( Just a, Just f ) ->
            Just (f a)

        _ ->
            Nothing


join : Maybe (Maybe a) -> Maybe a
join mma =
    case mma of
        Just ma ->
            ma

        Nothing ->
            Nothing
