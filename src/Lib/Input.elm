module Lib.Input exposing
    ( Type(..)
    , ViewOptions
    , float
    , nonNegativeFloat
    , nonNegativeInt
    , string
    , view
    )

import Field as F exposing (Field)
import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias ViewOptions a msg =
    { tipe : Type
    , isRequired : Bool
    , isDisabled : Bool
    , attrs : List (H.Attribute msg)
    , field : Field a
    , onInput : String -> msg
    }


type Type
    = String
    | Int
        { min : Maybe Int
        , max : Maybe Int
        }
    | Float
        { min : Maybe Float
        , max : Maybe Float
        }


string : Type
string =
    String


nonNegativeInt : Type
nonNegativeInt =
    Int { min = Just 0, max = Nothing }


float : Type
float =
    Float { min = Nothing, max = Nothing }


nonNegativeFloat : Type
nonNegativeFloat =
    Float { min = Just 0, max = Nothing }


view : ViewOptions a msg -> H.Html msg
view { tipe, isRequired, isDisabled, attrs, field, onInput } =
    let
        typeAttrs =
            typeToAttrs tipe

        requiredAttrs =
            if isRequired then
                [ HA.required True
                ]

            else
                []

        dataEmptyAttrs =
            if F.isEmpty field then
                [ HA.attribute "data-empty" ""
                ]

            else
                []

        otherAttrs =
            [ HA.value (F.toRawString field)
            , if isDisabled then
                HA.disabled True

              else
                HE.onInput onInput
            , HA.attribute "data-state" <|
                if F.isClean field then
                    "clean"

                else
                    "dirty"
            , HA.attribute "data-validity" <|
                if F.isValid field then
                    "valid"

                else
                    "invalid"
            ]
    in
    H.input (attrs ++ typeAttrs ++ requiredAttrs ++ dataEmptyAttrs ++ otherAttrs) []


typeToAttrs : Type -> List (H.Attribute msg)
typeToAttrs type_ =
    case type_ of
        String ->
            [ HA.type_ "text" ]

        Int { min, max } ->
            List.filterMap
                identity
                [ Just <| HA.type_ "number"
                , Maybe.map (HA.min << String.fromInt) min
                , Maybe.map (HA.max << String.fromInt) max
                ]

        Float { min, max } ->
            List.filterMap
                identity
                [ Just (HA.type_ "number")
                , Just (HA.step "any")
                , Maybe.map (HA.min << String.fromFloat) min
                , Maybe.map (HA.max << String.fromFloat) max
                ]
