module Data.Field exposing
    ( angle
    , fps
    , ipf
    , panIncrement
    , preset
    , zoomIncrement
    )

import Data.Angle as Angle exposing (Angle)
import Data.Preset as Preset exposing (Preset)
import Lib.Field as F


preset : F.Type Preset
preset =
    let
        toValue s =
            case Preset.fromId s of
                Just p ->
                    Ok p

                Nothing ->
                    Ok Preset.default
    in
    { toString = .id
    , toValue = toValue
    , validate = .id >> toValue
    }


angle : F.Type Angle
angle =
    { toString = Angle.toDegrees >> String.fromFloat
    , toValue = F.trim >> Result.andThen (String.toFloat >> Maybe.map (Ok << Angle.fromDegrees) >> Maybe.withDefault F.validationError)
    , validate = Ok
    }


fps : F.Type Int
fps =
    F.boundedInt { min = 1, max = 60 }


ipf : F.Type Int
ipf =
    F.boundedInt { min = 1, max = 1000000 }


panIncrement : F.Type Float
panIncrement =
    F.boundedFloat { min = 1, max = 1000000 }


zoomIncrement : F.Type Float
zoomIncrement =
    F.boundedFloat { min = 1, max = 1000 }
