module Lib.LabeledInput exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Lib.Field as Field exposing (Field)
import Lib.Input as Input


type alias ViewOptions e a msg =
    { label : String
    , tipe : Input.Type
    , isRequired : Bool
    , isDisabled : Bool
    , labelAttrs : List (H.Attribute msg)
    , inputAttrs : List (H.Attribute msg)
    , field : Field e a
    , onInput : String -> msg
    }


view : ViewOptions e a msg -> H.Html msg
view { label, tipe, isRequired, isDisabled, labelAttrs, inputAttrs, field, onInput } =
    H.label labelAttrs
        [ H.text label
        , H.text ": "
        , Input.view
            { tipe = tipe
            , isRequired = isRequired
            , isDisabled = isDisabled
            , attrs = inputAttrs
            , field = field
            , onInput = onInput
            }
        ]
