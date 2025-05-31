module Data.Settings exposing (Settings, default)

import Data.Angle as Angle exposing (Angle)
import Data.Color as Color exposing (Color)
import Data.Position exposing (Position)


type alias Settings =
    { startPosition : Position
    , startHeading : Angle
    , lineLength : Float
    , lineLengthScaleFactor : Float
    , lineWidth : Float
    , lineWidthIncrement : Float
    , turningAngle : Angle
    , turningAngleIncrement : Angle
    , lineColor : Color
    , fillColor : Color
    }


default : Settings
default =
    { startPosition = { x = 0, y = 0 }
    , startHeading = Angle.zero
    , lineLength = 1
    , lineLengthScaleFactor = 1
    , lineWidth = 1
    , lineWidthIncrement = 0
    , turningAngle = Angle.zero
    , turningAngleIncrement = Angle.zero
    , lineColor = Color.black
    , fillColor = Color.white
    }
