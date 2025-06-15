module Lib.Field exposing
    ( Error(..)
    , Field
    , Type
    , and
    , apply2
    , apply3
    , apply4
    , apply5
    , boundedFloat
    , boundedInt
    , char
    , customFloat
    , customInt
    , customString
    , fail
    , float
    , fromString
    , fromValue
    , get
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
    , setError
    , string
    , toMaybe
    , toResult
    , toString
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
    | Failure String
    | Custom e


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


char : (Char -> Bool) -> Type e Char
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


fail : String -> Result (Error e) a
fail =
    Err << Failure


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


setError : Error e -> Field e a -> Field e a
setError error (Field state) =
    Field { state | processed = Err error }


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


toResult : Field e a -> Result (Error e) a
toResult (Field { processed }) =
    processed


toMaybe : Field e a -> Maybe a
toMaybe (Field { processed }) =
    Result.toMaybe processed


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

                        Failure s ->
                            Failure s

                        Custom e1 ->
                            Custom (f e1)
                )
                state.processed
        }



--
-- The following are useful for mimicking an applicative style.
--


apply2 : (a -> b -> value) -> Field x a -> Field x b -> Result (Error x) value
apply2 f field1 field2 =
    Result.map2 f (toResult field1) (toResult field2)


apply3 : (a -> b -> c -> value) -> Field x a -> Field x b -> Field x c -> Result (Error x) value
apply3 f field1 field2 field3 =
    Result.map3 f (toResult field1) (toResult field2) (toResult field3)


apply4 : (a -> b -> c -> d -> value) -> Field x a -> Field x b -> Field x c -> Field x d -> Result (Error x) value
apply4 f field1 field2 field3 field4 =
    Result.map4 f (toResult field1) (toResult field2) (toResult field3) (toResult field4)


apply5 : (a -> b -> c -> d -> e -> value) -> Field x a -> Field x b -> Field x c -> Field x d -> Field x e -> Result (Error x) value
apply5 f field1 field2 field3 field4 field5 =
    Result.map5 f (toResult field1) (toResult field2) (toResult field3) (toResult field4) (toResult field5)


get : Field e a -> (a -> b) -> Result (Error e) b
get field f =
    Result.map f (toResult field)


and : Field e a -> Result (Error e) (a -> b) -> Result (Error e) b
and field rf =
    case ( toResult field, rf ) of
        ( Ok a, Ok f ) ->
            Ok (f a)

        ( Err e1, _ ) ->
            Err e1

        ( _, Err e2 ) ->
            Err e2
