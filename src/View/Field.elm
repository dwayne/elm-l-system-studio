module View.Field exposing
    ( Field
    , InitOptions
    , Msg
    , Processed(..)
    , Type(..)
    , UpdateOptions
    , ViewOptions
    , init
    , toValue
    , update
    , view
    )

import Html as H
import Html.Attributes as HA
import Html.Events as HE


type Field a e
    = Field (State a e)


type alias State a e =
    { raw : String
    , processed : Processed a e
    }


type Processed a e
    = Default a
    | Valid a
    | Invalid e


type alias InitOptions a e =
    { default : a
    , toRaw : a -> String
    , toProcessed : a -> Processed a e
    }


init : InitOptions a e -> Field a e
init { default, toRaw, toProcessed } =
    Field
        { raw = toRaw default
        , processed = toProcessed default
        }


type Msg
    = Input String


type alias UpdateOptions a e =
    { toProcessed : String -> Processed a e
    }


update : UpdateOptions a e -> Msg -> Field a e
update { toProcessed } msg =
    case msg of
        Input raw ->
            Field
                { raw = raw
                , processed = toProcessed raw
                }


type alias ViewOptions a e msg =
    { id : String
    , label : String
    , type_ : Type
    , isRequired : Bool
    , placeholder : String
    , field : Field a e
    , onChange : Msg -> msg
    }


type Type
    = Text
    | Number
        { min : Maybe Int
        , max : Maybe Int
        }


view : ViewOptions a e msg -> H.Html msg
view { id, label, type_, isRequired, placeholder, field, onChange } =
    let
        { raw, processed } =
            case field of
                Field state ->
                    state

        inputAttrs =
            List.concat
                [ [ HA.id id
                  , HA.required isRequired
                  , HA.placeholder placeholder
                  , HA.value raw
                  , HA.attribute "data-state" <|
                        case processed of
                            Default _ ->
                                "default"

                            Valid _ ->
                                "valid"

                            Invalid _ ->
                                "invalid"
                  , HE.onInput (onChange << Input)
                  ]
                , typeToAttrs type_
                ]
    in
    H.p []
        [ H.label [ HA.for id ] [ H.text label ]
        , H.span [] [ H.text ": " ]
        , H.input inputAttrs []
        ]


typeToAttrs : Type -> List (H.Attribute msg)
typeToAttrs type_ =
    case type_ of
        Text ->
            [ HA.type_ "text" ]

        Number { min, max } ->
            List.filterMap
                identity
                [ Just <| HA.type_ "number"
                , Maybe.map (HA.min << String.fromInt) min
                , Maybe.map (HA.max << String.fromInt) max
                ]


toValue : Field a e -> Result e a
toValue (Field { processed }) =
    case processed of
        Default a ->
            Ok a

        Valid a ->
            Ok a

        Invalid e ->
            Err e
