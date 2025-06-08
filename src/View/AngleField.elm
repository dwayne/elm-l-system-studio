module View.AngleField exposing (AngleField, ViewOptions, init, update, view)

import Data.Angle as Angle exposing (Angle)
import Html as H
import View.Field as Field exposing (Field)


type alias AngleField =
    Field Angle ()


init : Angle -> AngleField
init default =
    Field.init
        { default = default
        , toRaw = String.fromFloat << Angle.toDegrees
        , toProcessed = Field.Default
        }


update : Field.Msg -> AngleField
update =
    Field.update
        { toProcessed =
            \raw ->
                case String.toFloat raw of
                    Just theta ->
                        Field.Valid (Angle.fromDegrees theta)

                    Nothing ->
                        Field.Invalid ()
        }


type alias ViewOptions msg =
    { id : String
    , label : String
    , isRequired : Bool
    , placeholder : String
    , field : AngleField
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
                }
        , isRequired = isRequired
        , placeholder = placeholder
        , field = field
        , onChange = onChange
        }
