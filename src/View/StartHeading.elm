module View.StartHeading exposing (StartHeading, ViewOptions, init, update, view)

import Data.Angle exposing (Angle)
import Html as H
import View.AngleField as AngleField exposing (AngleField)
import View.Field as Field exposing (Field)


type alias StartHeading =
    AngleField


init : Angle -> StartHeading
init =
    AngleField.init


update : Field.Msg -> StartHeading
update =
    AngleField.update


type alias ViewOptions msg =
    { startHeading : StartHeading
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { startHeading, onChange } =
    AngleField.view
        { id = "start-heading"
        , label = "Start Heading"
        , isRequired = True
        , placeholder = "0"
        , field = startHeading
        , onChange = onChange
        }
