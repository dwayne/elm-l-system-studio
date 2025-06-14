module Data.Field exposing (angle)

import Data.Angle as Angle exposing (Angle)
import Lib.Field as Field


angle : Field.Type e Angle
angle =
    { toString = Angle.toDegrees >> String.fromFloat
    , toValue = Field.trim >> Result.andThen (String.toFloat >> Maybe.map (Ok << Angle.fromDegrees) >> Maybe.withDefault Field.validationError)
    , validate = Ok
    }
