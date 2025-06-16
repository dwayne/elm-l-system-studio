module Data.Settings exposing
    ( Settings
    , algae1
    , algae2
    , board
    , bush1
    , bush2
    , bush3
    , bush4
    , bush5
    , classicSierpinskiCurve
    , cross1
    , cross2
    , crystal
    , default
    , dragonCurve
    , hexagonalGosper
    , hilbert
    , kochCurve
    , kolam
    , krishnaAnklets
    , leaf
    , levyCurve
    , mangoLeaf
    , peanoCurve
    , pentaplexity
    , quadraticGosper
    , quadraticKochIsland1
    , quadraticKochIsland2
    , quadraticKochIsland3
    , quadraticSnowflake1
    , quadraticSnowflake2
    , rings
    , sierpinskiArrowhead
    , snakeKolam
    , squareSierpinski
    , sticks
    , tiles
    , toTransformOptions
    , toTranslateOptions
    , tree
    , triangle
    , vonKochSnowflake
    , weed
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


bush1 : Settings
bush1 =
    { default
        | rules =
            [ ( 'X', "X[-FFF][+FFF]FX" )
            , ( 'Y', "YFX[+Y][-Y]" )
            ]
        , axiom = "Y"
        , iterations = 5
        , lineLength = 2
        , startHeading = Angle.right
        , turningAngle = Angle.fromDegrees 25.7
        , windowPosition = { x = -60, y = -4 }
        , windowSize = 120
    }


bush2 : Settings
bush2 =
    { default
        | rules =
            [ ( 'F', "FF+[+F-F-F]-[-F+F+F]" )
            ]
        , axiom = "F"
        , iterations = 4
        , lineLength = 2
        , startHeading = Angle.right
        , turningAngle = Angle.fromDegrees 22.5
        , windowPosition = { x = -70, y = -4 }
        , windowSize = 120
    }


bush3 : Settings
bush3 =
    { default
        | rules =
            [ ( 'F', "F[+FF][-FF]F[-F][+F]F" )
            ]
        , axiom = "F"
        , iterations = 4
        , lineLength = 2
        , startHeading = Angle.right
        , turningAngle = Angle.fromDegrees 35
        , windowPosition = { x = -83, y = -2 }
        , windowSize = 166
    }


bush4 : Settings
bush4 =
    { default
        | rules =
            [ ( 'V', "[+++W][---W]YV" )
            , ( 'W', "+X[-W]Z" )
            , ( 'X', "-W[+X]Z" )
            , ( 'Y', "YZ" )
            , ( 'Z', "[-FFF][+FFF]F" )
            ]
        , axiom = "VZFFF"
        , iterations = 10
        , lineLength = 2
        , startHeading = Angle.right
        , turningAngle = Angle.fromDegrees 20
        , windowPosition = { x = -48, y = -12 }
        , windowSize = 102
    }


bush5 : Settings
bush5 =
    { default
        | rules =
            [ ( 'X', ">[-FX]+FX" )
            ]
        , axiom = "FX"
        , iterations = 10
        , lineLength = 10
        , lineLengthScaleFactor = 0.6
        , startHeading = Angle.right
        , turningAngle = Angle.fromDegrees 40
        , windowPosition = { x = -13, y = -1 }
        , windowSize = 26
    }


sticks : Settings
sticks =
    { default
        | rules =
            [ ( 'F', "FF" )
            , ( 'X', "F[+X]F[-X]+X" )
            ]
        , axiom = "X"
        , iterations = 7
        , lineLength = 1
        , startHeading = Angle.right
        , turningAngle = Angle.fromDegrees 20
        , windowPosition = { x = -129, y = -5 }
        , windowSize = 258
    }


algae1 : Settings
algae1 =
    { default
        | rules =
            [ ( 'a', "FFFFFv[+++h][---q]fb" )
            , ( 'b', "FFFFFv[+++h][---q]fc" )
            , ( 'c', "FFFFFv[+++fa]fd" )
            , ( 'd', "FFFFFv[+++h][---q]fe" )
            , ( 'e', "FFFFFv[+++h][---q]fg" )
            , ( 'g', "FFFFFv[---fa]fa" )
            , ( 'h', "ifFF" )
            , ( 'i', "fFFF[--m]j" )
            , ( 'j', "fFFF[--n]k" )
            , ( 'k', "fFFF[--o]l" )
            , ( 'l', "fFFF[--p]" )
            , ( 'm', "fFn" )
            , ( 'n', "fFo" )
            , ( 'o', "fFp" )
            , ( 'p', "fF" )
            , ( 'q', "rfF" )
            , ( 'r', "fFFF[++m]s" )
            , ( 's', "fFFF[++n]t" )
            , ( 't', "fFFF[++o]u" )
            , ( 'u', "fFFF[++p]" )
            , ( 'v', "Fv" )
            ]
        , axiom = "aF"
        , iterations = 17
        , lineLength = 1
        , startHeading = Angle.right
        , turningAngle = Angle.fromDegrees 12
        , windowPosition = { x = -153, y = -3 }
        , windowSize = 246
    }


algae2 : Settings
algae2 =
    --
    -- N.B. This one doesn't look quite right. Check the reference image. What could be the issue?
    --
    { default
        | rules =
            [ ( 'a', "FFFFFy[++++n][----t]fb" )
            , ( 'b', "+FFFFFy[++++n][----t]fc" )
            , ( 'c', "FFFFFy[++++n][----t]fd" )
            , ( 'd', "-FFFFFy[++++n][----t]fe" )
            , ( 'e', "FFFFFy[++++n][----t]fg" )
            , ( 'g', "FFFFFy[+++fa]fh" )
            , ( 'h', "FFFFFy[++++n][----t]fi" )
            , ( 'i', "+FFFFFy[++++n][----t]fj" )
            , ( 'j', "FFFFFy[++++n][----t]fk" )
            , ( 'k', "-FFFFFy[++++n][----t]fl" )
            , ( 'l', "FFFFFy[++++n][----t]fm" )
            , ( 'm', "FFFFFy[---fa]fa" )
            , ( 'n', "ofFFF" )
            , ( 'o', "fFFFp" )
            , ( 'p', "fFFF[-s]q" )
            , ( 'q', "fFFF[-s]r" )
            , ( 'r', "fFFF[-s]" )
            , ( 's', "fFfF" )
            , ( 't', "ufFFF" )
            , ( 'u', "fFFFv" )
            , ( 'v', "fFFF[+s]w" )
            , ( 'w', "fFFF[+s]x" )
            , ( 'x', "fFFF[+s]" )
            , ( 'y', "Fy" )
            ]
        , axiom = "aF"
        , iterations = 17
        , lineLength = 1
        , startHeading = Angle.right
        , turningAngle = Angle.fromDegrees 12
        , windowPosition = { x = -153, y = -3 }
        , windowSize = 246
    }


weed : Settings
weed =
    { default
        | rules =
            [ ( 'F', "FF-[XY]+[XY]" )
            , ( 'X', "+FY" )
            , ( 'Y', "-FX" )
            ]
        , axiom = "F"
        , iterations = 6
        , lineLength = 1
        , startHeading = Angle.right
        , turningAngle = Angle.fromDegrees 22.5
        , windowPosition = { x = -63, y = -1 }
        , windowSize = 126
    }


triangle : Settings
triangle =
    { default
        | rules =
            [ ( 'F', "F-F+F" )
            ]
        , axiom = "F+F+F"
        , iterations = 7
        , lineLength = 1
        , startHeading = Angle.right
        , turningAngle = Angle.fromDegrees 120
        , windowPosition = { x = -34, y = -56 }
        , windowSize = 62
    }


quadraticGosper : Settings
quadraticGosper =
    { default
        | rules =
            [ ( 'X', "XFX-YF-YF+FX+FX-YF-YFFX+YF+FXFXYF-FX+YF+FXFX+YF-FXYF-YF-FX+FX+YFYF-" )
            , ( 'Y', "+FXFX-YF-YF+FX+FXYF+FX-YFYF-FX-YF+FXYFYF-FX-YFFX+FX+YF-YF-FX+FX+YFY" )
            ]
        , axiom = "-YF"
        , iterations = 3
        , lineLength = 1
        , turningAngle = Angle.right
        , windowPosition = { x = -1, y = -127 }
        , windowSize = 128
    }


squareSierpinski : Settings
squareSierpinski =
    { default
        | rules =
            [ ( 'X', "XF-F+F-XF+F+XF-F+F-X" )
            ]
        , axiom = "F+XF+F+XF"
        , iterations = 5
        , lineLength = 1
        , startHeading = Angle.right
        , turningAngle = Angle.right
        , windowPosition = { x = -126, y = -64 }
        , windowSize = 128
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


quadraticSnowflake1 : Settings
quadraticSnowflake1 =
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


quadraticSnowflake2 : Settings
quadraticSnowflake2 =
    { default
        | rules =
            [ ( 'F', "F+F-F-F+F" )
            ]
        , axiom = "FF+FF+FF+FF"
        , iterations = 4
        , lineLength = 3
        , turningAngle = Angle.right
        , windowPosition = { x = -9, y = -10 }
        , windowSize = 506
    }


quadraticKochIsland1 : Settings
quadraticKochIsland1 =
    { default
        | rules =
            [ ( 'F', "F+F-F-FFF+F+F-F" )
            ]
        , axiom = "F+F+F+F"
        , iterations = 3
        , lineLength = 3
        , turningAngle = Angle.right
        , windowPosition = { x = -36, y = -178 }
        , windowSize = 370
    }


quadraticKochIsland2 : Settings
quadraticKochIsland2 =
    { default
        | rules =
            [ ( 'F', "F-FF+FF+F+F-F-FF+F+F-F-FF-FF+F" )
            ]
        , axiom = "F+F+F+F"
        , iterations = 2
        , lineLength = 3
        , turningAngle = Angle.right
        , windowPosition = { x = -43, y = -43 }
        , windowSize = 194
    }


quadraticKochIsland3 : Settings
quadraticKochIsland3 =
    { default
        | rules =
            [ ( 'X', "X+YF++YF-FX--FXFX-YF+X" )
            , ( 'Y', "-FX+YFYF++YF+FX--FX-YF" )
            ]
        , axiom = "X+X+X+X+X+X+X+X"
        , iterations = 3
        , lineLength = 0.5
        , turningAngle = Angle.fromDegrees 45
        , windowPosition = { x = -117, y = -22 }
        , windowSize = 140
    }


board : Settings
board =
    { default
        | rules =
            [ ( 'F', "FF+F+F+F+FF" )
            ]
        , axiom = "F+F+F+F"
        , iterations = 4
        , lineLength = 1
        , turningAngle = Angle.right
        , windowPosition = { x = -7, y = -7 }
        , windowSize = 94
    }


hilbert : Settings
hilbert =
    { default
        | rules =
            [ ( 'X', "-YF+XFX+FY-" )
            , ( 'Y', "+XF-YFY-FX+" )
            ]
        , axiom = "X"
        , iterations = 7
        , lineLength = 1
        , turningAngle = Angle.right
        , windowPosition = { x = -4, y = -131 }
        , windowSize = 135
    }


sierpinskiArrowhead : Settings
sierpinskiArrowhead =
    { default
        | rules =
            [ ( 'X', "YF+XF+Y" )
            , ( 'Y', "XF-YF-X" )
            ]
        , axiom = "YF"
        , iterations = 7
        , lineLength = 1
        , turningAngle = Angle.fromDegrees 60
        , windowPosition = { x = -4, y = -121 }
        , windowSize = 135
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


cross1 : Settings
cross1 =
    { default
        | rules =
            [ ( 'F', "F+FF++F+F" )
            ]
        , axiom = "F+F+F+F"
        , iterations = 5
        , lineLength = 1
        , turningAngle = Angle.right
        , windowPosition = { x = -84, y = -43 }
        , windowSize = 89
    }


cross2 : Settings
cross2 =
    { default
        | rules =
            [ ( 'F', "F+F-F+F+F" )
            ]
        , axiom = "F+F+F+F"
        , iterations = 5
        , lineLength = 1
        , turningAngle = Angle.right
        , windowPosition = { x = -7, y = -32 }
        , windowSize = 89
    }


pentaplexity : Settings
pentaplexity =
    { default
        | rules =
            [ ( 'F', "F++F++F|F-F++F" )
            ]
        , axiom = "F++F++F++F++F"
        , iterations = 4
        , lineLength = 1
        , turningAngle = Angle.fromDegrees 36
        , windowPosition = { x = -15, y = -3 }
        , windowSize = 77
    }


rings : Settings
rings =
    { default
        | rules =
            [ ( 'F', "FF+F+F+F+F+F-F" )
            ]
        , axiom = "F+F+F+F"
        , iterations = 4
        , lineLength = 1
        , turningAngle = Angle.right
        , windowPosition = { x = -106, y = -10 }
        , windowSize = 144
    }


dragonCurve : Settings
dragonCurve =
    { default
        | rules =
            [ ( 'X', "X+YF+" )
            , ( 'Y', "-FX-Y" )
            ]
        , axiom = "FX"
        , iterations = 12
        , lineLength = 1
        , turningAngle = Angle.right
        , windowPosition = { x = -75, y = -36 }
        , windowSize = 98
    }


hexagonalGosper : Settings
hexagonalGosper =
    { default
        | rules =
            [ ( 'X', "X+YF++YF-FX--FXFX-YF+" )
            , ( 'Y', "-FX+YFYF++YF+FX--FX-Y" )
            ]
        , axiom = "XF"
        , iterations = 4
        , lineLength = 1
        , turningAngle = Angle.fromDegrees 60
        , windowPosition = { x = -38, y = -2 }
        , windowSize = 58
    }


levyCurve : Settings
levyCurve =
    { default
        | rules =
            [ ( 'F', "-F++F-" )
            ]
        , axiom = "F"
        , iterations = 12
        , lineLength = 1
        , turningAngle = Angle.fromDegrees 45
        , windowPosition = { x = -33, y = -85 }
        , windowSize = 130
    }


classicSierpinskiCurve : Settings
classicSierpinskiCurve =
    { default
        | rules =
            [ ( 'X', "XF+F+XF--F--XF+F+X" )
            ]
        , axiom = "XF+F+XF--F--XF+F+X"
        , iterations = 4
        , lineLength = 1
        , turningAngle = Angle.fromDegrees 45
        , windowPosition = { x = -2, y = -30 }
        , windowSize = 110
    }


krishnaAnklets : Settings
krishnaAnklets =
    { default
        | rules =
            [ ( 'X', "XFX--XFX" )
            ]
        , axiom = "-X--X"
        , iterations = 6
        , lineLength = 1
        , turningAngle = Angle.fromDegrees 45
        , windowPosition = { x = -46, y = -91 }
        , windowSize = 92
    }


mangoLeaf : Settings
mangoLeaf =
    --
    -- TODO: Implement openPolygon and closePolygon.
    --
    { default
        | rules =
            [ ( 'X', "{F-F}{F-F}--[--X]{F-F}{F-F}--{F-F}{F-F}--" )
            , ( 'Y', "f-F+X+F-fY" )
            ]
        , axiom = "Y---Y"
        , iterations = 1
        , lineLength = 1
        , turningAngle = Angle.fromDegrees 60
        , windowPosition = { x = -2, y = -3 }
        , windowSize = 7
    }


snakeKolam : Settings
snakeKolam =
    --
    -- TODO: Implement openPolygon and closePolygon.
    --
    { default
        | rules =
            [ ( 'X', "X{F-F-F}+XF+F+X{F-F-F}+X" )
            ]
        , axiom = "F+XF+F+XF"
        , iterations = 1
        , lineLength = 1
        , turningAngle = Angle.right
        , windowPosition = { x = -60, y = -160 }
        , windowSize = 600
    }


kolam : Settings
kolam =
    { default
        | rules =
            [ ( 'A', "F++FFFF--F--FFFF++F++FFFF--F" )
            , ( 'B', "F--FFFF++F++FFFF--F--FFFF++F" )
            , ( 'C', "BFA--BFA" )
            , ( 'D', "CFC--CFC" )
            ]
        , axiom = "(-D--D)"
        , iterations = 3
        , lineLength = 1
        , turningAngle = Angle.fromDegrees 45
        , windowPosition = { x = -15, y = -28 }
        , windowSize = 30
    }
