module Lib.Field exposing
    ( Error(..)
    , Field
    , Type
    , and
    , apply2
    , apply4
    , boundedFloat
    , boundedInt
    , char
    , float
    , fromString
    , fromValue
    , get
    , isClean
    , isEmpty
    , isInvalid
    , isValid
    , nonEmptyString
    , nonNegativeFloat
    , nonNegativeInt
    , toMaybe
    , toString
    , trim
    , validationError
    )


type Field a
    = Field (State a)


type alias State a =
    { raw : Raw
    , processed : Result Error a
    }


type Raw
    = Initial String
    | Dirty String


type Error
    = Required
    | ParseError
    | ValidationError


type alias Type a =
    { toString : a -> String
    , toValue : String -> Result Error a
    , validate : a -> Result Error a
    }


nonNegativeInt : Type Int
nonNegativeInt =
    customInt
        (\n ->
            if n >= 0 then
                Ok n

            else
                validationError
        )


boundedInt : { min : Int, max : Int } -> Type Int
boundedInt { min, max } =
    customInt
        (\n ->
            if min <= n && n <= max then
                Ok n

            else
                validationError
        )


customInt : (Int -> Result Error Int) -> Type Int
customInt validate =
    { toString = String.fromInt
    , toValue = trim >> Result.andThen (String.toInt >> Maybe.map validate >> Maybe.withDefault parseError)
    , validate = validate
    }


float : Type Float
float =
    customFloat Ok


nonNegativeFloat : Type Float
nonNegativeFloat =
    customFloat
        (\f ->
            if f >= 0 then
                Ok f

            else
                validationError
        )


boundedFloat : { min : Float, max : Float } -> Type Float
boundedFloat { min, max } =
    customFloat
        (\f ->
            if min <= f && f <= max then
                Ok f

            else
                validationError
        )


customFloat : (Float -> Result Error Float) -> Type Float
customFloat validate =
    { toString = String.fromFloat
    , toValue = trim >> Result.andThen (String.toFloat >> Maybe.map validate >> Maybe.withDefault parseError)
    , validate = validate
    }


nonEmptyString : Type String
nonEmptyString =
    customString trim


customString : (String -> Result Error String) -> Type String
customString validate =
    { toString = identity
    , toValue = validate
    , validate = validate
    }


char : (Char -> Bool) -> Type Char
char isGood =
    let
        validate ch =
            if isGood ch then
                Ok ch

            else
                validationError
    in
    { toString = String.fromChar
    , toValue =
        \s ->
            case String.uncons s of
                Just ( ch, "" ) ->
                    validate ch

                Just _ ->
                    validationError

                Nothing ->
                    required
    , validate = validate
    }


trim : String -> Result Error String
trim s =
    let
        t =
            String.trim s
    in
    if String.isEmpty t then
        required

    else
        Ok t


required : Result Error a
required =
    Err Required


parseError : Result Error a
parseError =
    Err ParseError


validationError : Result Error a
validationError =
    Err ValidationError


fromString : Type a -> Bool -> String -> Field a
fromString tipe isInitial s =
    Field
        { raw =
            (if isInitial then
                Initial

             else
                Dirty
            )
                s
        , processed = tipe.toValue s
        }


fromValue : Type a -> Bool -> a -> Field a
fromValue tipe isInitial value =
    Field
        { raw =
            (if isInitial then
                Initial

             else
                Dirty
            )
                (tipe.toString value)
        , processed = tipe.validate value
        }


isEmpty : Field a -> Bool
isEmpty (Field { raw }) =
    case raw of
        Initial s ->
            String.isEmpty s

        Dirty s ->
            String.isEmpty s


isClean : Field a -> Bool
isClean (Field { raw }) =
    case raw of
        Initial _ ->
            True

        _ ->
            False


isValid : Field a -> Bool
isValid (Field { processed }) =
    case processed of
        Ok _ ->
            True

        _ ->
            False


isInvalid : Field a -> Bool
isInvalid (Field { processed }) =
    case processed of
        Err _ ->
            True

        _ ->
            False


toString : Field a -> String
toString (Field { raw }) =
    case raw of
        Initial s ->
            s

        Dirty s ->
            s


toResult : Field a -> Result Error a
toResult (Field { processed }) =
    processed


toMaybe : Field a -> Maybe a
toMaybe (Field { processed }) =
    Result.toMaybe processed



--
-- The following are useful for mimicking an applicative style.
--


apply2 : (a -> b -> value) -> Field a -> Field b -> Result Error value
apply2 f field1 field2 =
    Result.map2 f (toResult field1) (toResult field2)


apply4 : (a -> b -> c -> d -> value) -> Field a -> Field b -> Field c -> Field d -> Result Error value
apply4 f field1 field2 field3 field4 =
    Result.map4 f (toResult field1) (toResult field2) (toResult field3) (toResult field4)


get : Field a -> (a -> b) -> Result Error b
get field f =
    Result.map f (toResult field)


and : Field a -> Result Error (a -> b) -> Result Error b
and field rf =
    case ( toResult field, rf ) of
        ( Ok a, Ok f ) ->
            Ok (f a)

        ( Err e1, _ ) ->
            Err e1

        ( _, Err e2 ) ->
            Err e2
