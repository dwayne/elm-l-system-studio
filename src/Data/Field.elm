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
import Field as F exposing (Type)


preset : Type Preset
preset =
    F.customType
        { fromString =
            \s ->
                case Preset.fromId s of
                    Just p ->
                        Ok p

                    Nothing ->
                        Ok Preset.default
        , toString = .id
        }


angle : Type Angle
angle =
    let
        float =
            F.typeToConverters F.float
    in
    F.customType
        { fromString = float.fromString >> Result.map Angle.fromDegrees
        , toString = Angle.toDegrees >> float.toString
        }


fps : Type Int
fps =
    F.subsetOfInt (\n -> 1 <= n && n <= 60)


ipf : Type Int
ipf =
    F.subsetOfInt (\n -> 1 <= n && n <= 1000000)


panIncrement : Type Float
panIncrement =
    F.subsetOfFloat (\f -> 1 <= f && f <= 1000000)


zoomIncrement : Type Float
zoomIncrement =
    F.subsetOfFloat (\f -> 1 <= f && f <= 1000)
