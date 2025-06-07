module Data.Settings exposing (Settings, default, toTransformOptions, toTranslateOptions)

import Data.Angle exposing (Angle)
import Data.Color exposing (Color)
import Data.Dictionary as Dictionary exposing (Dictionary)
import Data.Position exposing (Position)
import Data.Transformer as Transformer
import Data.Translator as Translator


type alias Settings =
    { rules : List ( Char, String )
    , axiom : String
    , iterations : Int
    , dictionary : Dictionary
    , startPosition : Position
    , startHeading : Angle
    , lineLength : Float
    , lineLengthScaleFactor : Float
    , lineWidth : Float
    , lineWidthIncrement : Float
    , turningAngle : Angle
    , turningAngleIncrement : Angle
    , lineColor : Color
    , fillColor : Color
    , windowPosition : Position
    , windowSize : Float
    , canvasSize : Int
    , fps : Int
    , ipf : Int
    }


default : List ( Char, String ) -> String -> Settings
default rules axiom =
    let
        translateOptions =
            Translator.default

        transformOptions =
            Transformer.default
    in
    { rules = rules
    , axiom = axiom
    , iterations = 3
    , dictionary = Dictionary.default
    , startPosition = translateOptions.startPosition
    , startHeading = translateOptions.startHeading
    , lineLength = translateOptions.lineLength
    , lineLengthScaleFactor = translateOptions.lineLengthScaleFactor
    , lineWidth = translateOptions.lineWidth
    , lineWidthIncrement = translateOptions.lineWidthIncrement
    , turningAngle = translateOptions.turningAngle
    , turningAngleIncrement = translateOptions.turningAngleIncrement
    , lineColor = translateOptions.lineColor
    , fillColor = translateOptions.fillColor
    , windowPosition = transformOptions.windowPosition
    , windowSize = transformOptions.windowSize
    , canvasSize = transformOptions.canvasSize
    , fps = 60
    , ipf = 100
    }


toTranslateOptions : Settings -> Translator.TranslateOptions
toTranslateOptions settings =
    { startPosition = settings.startPosition
    , startHeading = settings.startHeading
    , lineLength = settings.lineLength
    , lineLengthScaleFactor = settings.lineLengthScaleFactor
    , lineWidth = settings.lineWidth
    , lineWidthIncrement = settings.lineWidthIncrement
    , turningAngle = settings.turningAngle
    , turningAngleIncrement = settings.turningAngleIncrement
    , lineColor = settings.lineColor
    , fillColor = settings.fillColor
    }


toTransformOptions : Settings -> Transformer.TransformOptions
toTransformOptions settings =
    { windowPosition = settings.windowPosition
    , windowSize = settings.windowSize
    , canvasSize = settings.canvasSize
    }
