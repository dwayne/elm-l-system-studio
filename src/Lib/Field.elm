module Lib.Field exposing
    ( Config
    , Field
    , float
    , fromString
    , fromValue
    , int
    , isClean
    , isDirty
    , nonEmptyString
    , nonNegativeInt
    , setFromString
    , setFromValue
    , string
    , toString
    , toValue
    )


type Field e a
    = Field (Config e a) (State e a)


type alias Config e a =
    { toString : a -> String
    , toValue : String -> Result e a
    , validate : a -> Result e a
    }


int : Config () Int
int =
    { toString = String.fromInt
    , toValue = String.toInt >> Result.fromMaybe ()
    , validate = Ok
    }


nonNegativeInt : Config () Int
nonNegativeInt =
    let
        validate n =
            if n >= 0 then
                Ok n

            else
                error
    in
    { toString = String.fromInt
    , toValue = String.toInt >> Maybe.map validate >> Maybe.withDefault error
    , validate = validate
    }


float : Config () Float
float =
    { toString = String.fromFloat
    , toValue = String.toFloat >> Result.fromMaybe ()
    , validate = Ok
    }


string : Config () String
string =
    { toString = identity
    , toValue = Ok
    , validate = Ok
    }


nonEmptyString : Config () String
nonEmptyString =
    let
        validate s =
            let
                t =
                    String.trim s
            in
            if t == "" then
                error

            else
                Ok t
    in
    { toString = identity
    , toValue = validate
    , validate = validate
    }


error : Result () a
error =
    Err ()


type alias State e a =
    { raw : Raw
    , processed : Result e a
    }


type Raw
    = Initial String
    | Dirty String


fromString : String -> Config e a -> Field e a
fromString s config =
    Field config
        { raw = Initial s
        , processed = config.toValue s
        }


fromValue : a -> Config e a -> Field e a
fromValue value config =
    Field config
        { raw = Initial (config.toString value)
        , processed = config.validate value
        }


isClean : Field e a -> Bool
isClean (Field _ { raw }) =
    case raw of
        Initial _ ->
            True

        _ ->
            False


isDirty : Field e a -> Bool
isDirty (Field _ { raw }) =
    case raw of
        Dirty _ ->
            True

        _ ->
            False


setFromString : String -> Field e a -> Field e a
setFromString s (Field config state) =
    Field config
        { raw = Dirty s
        , processed = config.toValue s
        }


setFromValue : a -> Field e a -> Field e a
setFromValue value (Field config state) =
    Field config
        { raw = Dirty (config.toString value)
        , processed = config.validate value
        }


toString : Field e a -> String
toString (Field _ { raw }) =
    case raw of
        Initial s ->
            s

        Dirty s ->
            s


toValue : Field e a -> Result e a
toValue (Field _ { processed }) =
    processed
