module View.NonNegativeFloatField exposing (NonNegativeFloatField, ViewOptions, init, update, view)

import Html as H
import View.Field as Field exposing (Field)


type alias NonNegativeFloatField =
    Field Float ()


init : Float -> NonNegativeFloatField
init default =
    Field.init
        { default = default
        , toRaw = String.fromFloat
        , toProcessed =
            \f ->
                if f >= 0 then
                    Field.Default f

                else
                    Field.Invalid ()
        }


update : Field.Msg -> NonNegativeFloatField
update =
    Field.update
        { toProcessed =
            \raw ->
                case String.toFloat raw of
                    Just f ->
                        if f >= 0 then
                            Field.Valid f

                        else
                            Field.Invalid ()

                    Nothing ->
                        Field.Invalid ()
        }


type alias ViewOptions msg =
    { id : String
    , label : String
    , isRequired : Bool
    , placeholder : String
    , field : NonNegativeFloatField
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { id, label, isRequired, placeholder, field, onChange } =
    Field.view
        { id = id
        , label = label
        , type_ =
            Field.Float
                { min = Just 0
                }
        , isRequired = isRequired
        , placeholder = placeholder
        , field = field
        , onChange = onChange
        }
