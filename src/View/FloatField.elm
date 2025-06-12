module View.FloatField exposing (FloatField, ViewOptions, changeBy, init, setValue, update, view)

import Html as H
import View.Field as Field exposing (Field)


type alias FloatField =
    Field Float ()


init : Float -> FloatField
init default =
    Field.init
        { default = default
        , toRaw = String.fromFloat
        , toProcessed = Field.Default
        }


setValue : Float -> FloatField
setValue value =
    Field.init
        { default = value
        , toRaw = String.fromFloat
        , toProcessed = Field.Valid
        }


changeBy : Float -> FloatField -> FloatField
changeBy delta field =
    case Field.toValue field of
        Just value ->
            Field.init
                { default = value + delta
                , toRaw = String.fromFloat
                , toProcessed = Field.Valid
                }

        Nothing ->
            field


update : Field.Msg -> FloatField
update =
    Field.update
        { toProcessed =
            \raw ->
                case String.toFloat raw of
                    Just f ->
                        Field.Valid f

                    Nothing ->
                        Field.Invalid ()
        }


type alias ViewOptions msg =
    { id : String
    , label : String
    , isRequired : Bool
    , placeholder : String
    , field : FloatField
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { id, label, isRequired, placeholder, field, onChange } =
    Field.view
        { id = id
        , label = label
        , type_ =
            Field.Float
                { min = Nothing
                , max = Nothing
                }
        , isRequired = isRequired
        , placeholder = placeholder
        , field = field
        , onChange = onChange
        }
