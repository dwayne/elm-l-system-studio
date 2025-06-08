module View.StartHeading exposing (StartHeading, ViewOptions, init, update, view)

import Data.Angle as Angle exposing (Angle)
import Html as H
import View.Field as Field exposing (Field)


type alias StartHeading =
    Field Angle ()


init : Angle -> StartHeading
init default =
    Field.init
        { default = default
        , toRaw = String.fromFloat << Angle.toDegrees
        , toProcessed = Field.Default
        }


update : Field.Msg -> StartHeading
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
    { startHeading : StartHeading
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { startHeading, onChange } =
    Field.view
        { id = "start-heading"
        , label = "Start Heading"
        , type_ = Field.Float
        , isRequired = True
        , placeholder = "0"
        , field = startHeading
        , onChange = onChange
        }
