module Lib.Field exposing
    ( Field
    , Type
    , boundedFloat
    , boundedInt
    , float
    , fromString
    , fromValue
    , int
    , isClean
    , isDirty
    , isEmpty
    , isInvalid
    , isValid
    , mapError
    , nonEmptyString
    , nonNegativeFloat
    , nonNegativeInt
    , optional
    , optionalFloat
    , optionalInt
    , parseError
    , positiveFloat
    , positiveInt
    , required
    , string
    , toString
    , toValue
    , trim
    , validationError
    )


type Field e a
    = Field (State e a)


type alias State e a =
    { raw : Raw
    , processed : Result (Error e) a
    }


type Raw
    = Initial String
    | Dirty String


type Error e
    = Required
    | ParseError
    | ValidationError
    | Custom e



---
--- TODO: Flesh out ValidationError.
---


type alias Type e a =
    { toString : a -> String
    , toValue : String -> Result (Error e) a
    , validate : a -> Result (Error e) a
    }


int : Type e Int
int =
    customInt Ok


nonNegativeInt : Type e Int
nonNegativeInt =
    customInt
        (\n ->
            if n >= 0 then
                Ok n

            else
                validationError
        )


positiveInt : Type e Int
positiveInt =
    customInt
        (\n ->
            if n > 0 then
                Ok n

            else
                validationError
        )


boundedInt : { min : Int, max : Int } -> Type e Int
boundedInt { min, max } =
    customInt
        (\n ->
            if min <= n && n <= max then
                Ok n

            else
                validationError
        )


customInt : (Int -> Result (Error e) Int) -> Type e Int
customInt validate =
    { toString = String.fromInt
    , toValue = trim >> Result.andThen (String.toInt >> Maybe.map validate >> Maybe.withDefault parseError)
    , validate = validate
    }


optionalInt : Type e (Maybe Int)
optionalInt =
    { toString = Maybe.map String.fromInt >> Maybe.withDefault ""
    , toValue =
        optional
            (\s ->
                case String.toInt s of
                    Just n ->
                        Ok (Just n)

                    Nothing ->
                        parseError
            )
    , validate = Ok
    }


float : Type e Float
float =
    customFloat Ok


nonNegativeFloat : Type e Float
nonNegativeFloat =
    customFloat
        (\f ->
            if f >= 0 then
                Ok f

            else
                validationError
        )


positiveFloat : Type e Float
positiveFloat =
    customFloat
        (\f ->
            if f > 0 then
                Ok f

            else
                validationError
        )


boundedFloat : { min : Float, max : Float } -> Type e Float
boundedFloat { min, max } =
    customFloat
        (\f ->
            if min <= f && f <= max then
                Ok f

            else
                validationError
        )


customFloat : (Float -> Result (Error e) Float) -> Type e Float
customFloat validate =
    { toString = String.fromFloat
    , toValue = trim >> Result.andThen (String.toFloat >> Maybe.map validate >> Maybe.withDefault parseError)
    , validate = validate
    }


optionalFloat : Type e (Maybe Float)
optionalFloat =
    { toString = Maybe.map String.fromFloat >> Maybe.withDefault ""
    , toValue =
        optional
            (\s ->
                case String.toFloat s of
                    Just f ->
                        Ok (Just f)

                    Nothing ->
                        parseError
            )
    , validate = Ok
    }


string : Type e String
string =
    customString (String.trim >> Ok)


nonEmptyString : Type e String
nonEmptyString =
    customString trim


customString : (String -> Result (Error e) String) -> Type e String
customString validate =
    { toString = identity
    , toValue = validate
    , validate = validate
    }


trim : String -> Result (Error e) String
trim s =
    let
        t =
            String.trim s
    in
    if String.isEmpty t then
        required

    else
        Ok t


optional : (String -> Result (Error e) (Maybe a)) -> String -> Result (Error e) (Maybe a)
optional parse s =
    let
        t =
            String.trim s
    in
    if String.isEmpty t then
        Ok Nothing

    else
        parse t


required : Result (Error e) a
required =
    Err Required


parseError : Result (Error e) a
parseError =
    Err ParseError


validationError : Result (Error e) a
validationError =
    Err ValidationError


fromString : Type e a -> Bool -> String -> Field e a
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


fromValue : Type e a -> Bool -> a -> Field e a
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


isEmpty : Field e a -> Bool
isEmpty (Field { raw }) =
    case raw of
        Initial s ->
            String.isEmpty s

        Dirty s ->
            String.isEmpty s


isClean : Field e a -> Bool
isClean (Field { raw }) =
    case raw of
        Initial _ ->
            True

        _ ->
            False


isDirty : Field e a -> Bool
isDirty (Field { raw }) =
    case raw of
        Dirty _ ->
            True

        _ ->
            False


isValid : Field e a -> Bool
isValid (Field { processed }) =
    case processed of
        Ok _ ->
            True

        _ ->
            False


isInvalid : Field e a -> Bool
isInvalid (Field { processed }) =
    case processed of
        Err _ ->
            True

        _ ->
            False


toString : Field e a -> String
toString (Field { raw }) =
    case raw of
        Initial s ->
            s

        Dirty s ->
            s


toValue : Field e a -> Result (Error e) a
toValue (Field { processed }) =
    processed


mapError : (e1 -> e2) -> Field e1 a -> Field e2 a
mapError f (Field state) =
    Field
        { raw = state.raw
        , processed =
            Result.mapError
                (\error ->
                    case error of
                        Required ->
                            Required

                        ParseError ->
                            ParseError

                        ValidationError ->
                            ValidationError

                        Custom e1 ->
                            Custom (f e1)
                )
                state.processed
        }
