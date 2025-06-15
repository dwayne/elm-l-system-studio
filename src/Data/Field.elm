module Data.Field exposing (angle, fps, ipf)

import Data.Angle as Angle exposing (Angle)
import Lib.Field as Field


angle : Field.Type e Angle
angle =
    { toString = Angle.toDegrees >> String.fromFloat
    , toValue = Field.trim >> Result.andThen (String.toFloat >> Maybe.map (Ok << Angle.fromDegrees) >> Maybe.withDefault Field.validationError)
    , validate = Ok
    }


fps : Field.Type e Int
fps =
    Field.boundedInt { min = 1, max = 60 }


ipf : Field.Type e Int
ipf =
    Field.boundedInt { min = 1, max = 1000000 }
