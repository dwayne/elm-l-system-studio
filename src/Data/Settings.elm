module Data.Settings exposing
    ( Settings
    , crystal
    , default
    , kochCurve
    , leaf
    , peanoCurve
    , quadraticSnowflake
    , tiles
    , toTransformOptions
    , toTranslateOptions
    , tree
    , vonKochSnowflake
    )

import Data.Angle as Angle exposing (Angle)
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


default : Settings
default =
    let
        translateOptions =
            Translator.default

        transformOptions =
            Transformer.default
    in
    { rules = []
    , axiom = ""
    , iterations = 0
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
    , fps = 1
    , ipf = 1
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



-- PRESETS


kochCurve : Settings
kochCurve =
    { default
        | rules =
            [ ( 'F', "F+F-F-FF+F+F-F" )
            ]
        , axiom = "F+F+F+F"
        , iterations = 3
        , turningAngle = Angle.right
        , windowPosition = { x = -22, y = -22 }
        , windowSize = 108
    }


tiles : Settings
tiles =
    { default
        | rules =
            [ ( 'F', "FF+F-F+F+FF" )
            ]
        , axiom = "F+F+F+F"
        , iterations = 3
        , lineLength = 10
        , turningAngle = Angle.right
        , windowPosition = { x = -200, y = -150 }
        , windowSize = 250
    }


tree : Settings
tree =
    { default
        | rules =
            [ ( 'F', "FF" )
            , ( 'X', "F-[[X]+X]+F[+FX]-X" )
            ]
        , axiom = "X"
        , iterations = 6
        , startHeading = Angle.right
        , turningAngle = Angle.fromDegrees 22.5
        , windowPosition = { x = -100, y = -20 }
        , windowSize = 200
    }


leaf : Settings
leaf =
    { default
        | rules =
            [ ( 'F', ">F<" )
            , ( 'a', "F[+x]Fb" )
            , ( 'b', "F[-y]Fa" )
            , ( 'x', "a" )
            , ( 'y', "b" )
            ]
        , axiom = "a"
        , iterations = 15
        , startHeading = Angle.right
        , lineLengthScaleFactor = 1.36
        , turningAngle = Angle.fromDegrees 45
        , windowPosition = { x = -310, y = -10 }
        , windowSize = 600
    }


crystal : Settings
crystal =
    { default
        | rules =
            [ ( 'F', "FF+F++F+F" )
            ]
        , axiom = "F+F+F+F"
        , iterations = 5
        , lineLength = 5
        , turningAngle = Angle.right
        , windowPosition = { x = -140, y = -125 }
        , windowSize = 1500
    }


peanoCurve : Settings
peanoCurve =
    { default
        | rules =
            [ ( 'X', "XFYFX+F+YFXFY-F-XFYFX" )
            , ( 'Y', "YFXFY-F-XFYFX+F+YFXFY" )
            ]
        , axiom = "X"
        , iterations = 4
        , startHeading = Angle.right
        , lineLength = 5
        , turningAngle = Angle.right
        , windowPosition = { x = -405, y = -5 }
        , windowSize = 410
    }


quadraticSnowflake : Settings
quadraticSnowflake =
    { default
        | rules =
            [ ( 'F', "F-F+F+F-F" )
            ]
        , axiom = "F"
        , iterations = 5
        , lineLength = 3
        , turningAngle = Angle.right
        , windowPosition = { x = -10, y = -500 }
        , windowSize = 750
    }


vonKochSnowflake : Settings
vonKochSnowflake =
    { default
        | rules =
            [ ( 'F', "F-F++F-F" )
            ]
        , axiom = "F++F++F"
        , iterations = 4
        , lineLength = 6
        , turningAngle = Angle.fromDegrees 60
        , windowPosition = { x = -60, y = -160 }
        , windowSize = 600
    }
