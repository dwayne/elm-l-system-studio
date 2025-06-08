module View.TurningAngle exposing (TurningAngle, ViewOptions, init, update, view)

import Data.Angle exposing (Angle)
import Html as H
import View.AngleField as AngleField exposing (AngleField)
import View.Field as Field exposing (Field)


type alias TurningAngle =
    AngleField


init : Angle -> TurningAngle
init =
    AngleField.init


update : Field.Msg -> TurningAngle
update =
    AngleField.update


type alias ViewOptions msg =
    { turningAngle : TurningAngle
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { turningAngle, onChange } =
    AngleField.view
        { id = "turning-angle"
        , label = "Turning Angle"
        , isRequired = True
        , placeholder = "90"
        , field = turningAngle
        , onChange = onChange
        }
