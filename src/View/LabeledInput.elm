module View.LabeledInput exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA
import Lib.Field exposing (Field)
import Lib.Input as Input


type alias ViewOptions a msg =
    { id : String
    , label : String
    , tipe : Input.Type
    , isRequired : Bool
    , isDisabled : Bool
    , attrs : List (H.Attribute msg)
    , field : Field a
    , onInput : String -> msg
    }


view : ViewOptions a msg -> H.Html msg
view { id, label, tipe, isRequired, isDisabled, attrs, field, onInput } =
    H.p []
        [ H.label [ HA.for id ] [ H.text (label ++ ": ") ]
        , Input.view
            { tipe = tipe
            , isRequired = isRequired
            , isDisabled = isDisabled
            , attrs = attrs ++ [ HA.id id ]
            , field = field
            , onInput = onInput
            }
        ]
