module Test.Data.Optimizer exposing (suite)

import Data.Angle as Angle
import Data.Dictionary as Dictionary
import Data.Generator as Generator
import Data.Optimizer as Optimizer
import Data.Settings as Settings exposing (Settings)
import Data.Transformer as Transformer exposing (Instruction(..))
import Data.Translator as Translator
import Expect
import Lib.Sequence as Sequence
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Data.Translator"
        [ test "MoveTo followed by MoveTo" <|
            \_ ->
                Sequence.fromString "fffff"
                    |> Translator.translate Dictionary.default defaultSettings
                    |> Transformer.transform transformOptions
                    |> Optimizer.simplify
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo { x = 5, y = 0 } ]
        , test "LineTo followed by LineTo (equal y-coordinates)" <|
            \_ ->
                Sequence.fromString "FFFFF"
                    |> Translator.translate Dictionary.default defaultSettings
                    |> Transformer.transform transformOptions
                    |> Optimizer.simplify
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo { x = 0, y = 0 }, LineTo { position = { x = 5, y = 0 }, lineWidth = 1 } ]
        , test "LineTo followed by LineTo (equal x-coordinates)" <|
            \_ ->
                let
                    settings =
                        { defaultSettings | startHeading = Angle.right }
                in
                Sequence.fromString "FFFFF"
                    |> Translator.translate Dictionary.default settings
                    |> Transformer.transform transformOptions
                    |> Optimizer.simplify
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo { x = 0, y = 0 }, LineTo { position = { x = 0, y = -5 }, lineWidth = 1 } ]
        , test "LineTo followed by LineTo (equal y-coordinates followed by equal x-coordinates)" <|
            \_ ->
                let
                    settings =
                        { defaultSettings | turningAngle = Angle.right }
                in
                Sequence.fromString "FFFFF+FFFFF"
                    |> Translator.translate Dictionary.default settings
                    |> Transformer.transform transformOptions
                    |> Optimizer.simplify
                    |> Sequence.toList
                    |> Expect.equal
                        [ MoveTo { x = 0, y = 0 }
                        , LineTo { position = { x = 5, y = 0 }, lineWidth = 1 }
                        , LineTo { position = { x = 5, y = -5 }, lineWidth = 1 }
                        ]
        , test "LineTo followed by LineTo (equal x-coordinates followed by equal y-coordinates)" <|
            \_ ->
                let
                    settings =
                        { defaultSettings | startHeading = Angle.right, turningAngle = Angle.right }
                in
                Sequence.fromString "FFFFF+FFFFF"
                    |> Translator.translate Dictionary.default settings
                    |> Transformer.transform transformOptions
                    |> Optimizer.simplify
                    |> Sequence.toList
                    |> Expect.equal
                        [ MoveTo { x = 0, y = 0 }
                        , LineTo { position = { x = 0, y = -5 }, lineWidth = 1 }
                        , LineTo { position = { x = -5, y = -5 }, lineWidth = 1 }
                        ]
        , test "A general example" <|
            \_ ->
                let
                    rules =
                        [ ( 'F', "F+F-F-FF+F+F-F" ) ]

                    axiom =
                        "F+F+F+F"

                    settings =
                        { defaultSettings | turningAngle = Angle.right }
                in
                --
                -- TODO: Check what the actual values are now.
                --
                -- [ MoveTo { x = 0, y = 0 }
                --
                --, LineTo { lineWidth = 1, position = { x = 1, y = 0 } }
                --, LineTo { lineWidth = 1, position = { x = 1, y = -1 } }
                --
                --, LineTo { lineWidth = 1, position = { x = 2, y = -1 } }
                --, LineTo { lineWidth = 1, position = { x = 2, y = 0 } }
                --, LineTo { lineWidth = 1, position = { x = 2, y = 1 } }
                --
                --, LineTo { lineWidth = 1, position = { x = 3, y = 1 } }
                --, LineTo { lineWidth = 1, position = { x = 3, y = 0 } }
                --
                --, LineTo { lineWidth = 1, position = { x = 4, y = 0 } }
                --, LineTo { lineWidth = 1, position = { x = 4, y = -1 } }
                --
                --, LineTo { lineWidth = 1, position = { x = 3, y = -1 } }
                --, LineTo { lineWidth = 1, position = { x = 3, y = -2 } }
                --
                --, LineTo { lineWidth = 1, position = { x = 4, y = -2 } }
                --, LineTo { lineWidth = 1, position = { x = 5, y = -2 } }
                --
                --, LineTo { lineWidth = 1, position = { x = 5, y = -3 } }
                --, LineTo { lineWidth = 1, position = { x = 4, y = -3 } }
                --
                --, LineTo { lineWidth = 1, position = { x = 4, y = -4 } }
                --, LineTo { lineWidth = 1, position = { x = 3, y = -4 } }
                --
                --, LineTo { lineWidth = 1, position = { x = 3, y = -3 } }
                --, LineTo { lineWidth = 1, position = { x = 2, y = -3 } }
                --
                --, LineTo { lineWidth = 1, position = { x = 2, y = -4 } }
                --
                --, LineTo { lineWidth = 1, position = { x = 2, y = -5 } }
                --, LineTo { lineWidth = 1, position = { x = 1, y = -5 } }
                --
                --, LineTo { lineWidth = 1, position = { x = 1, y = -4 } }
                --, LineTo { lineWidth = 1, position = { x = 0, y = -4 } }
                --
                --, LineTo { lineWidth = 1, position = { x = 0, y = -3 } }
                --, LineTo { lineWidth = 1, position = { x = 1, y = -3 } }
                --
                --, LineTo { lineWidth = 1, position = { x = 1, y = -2 } }
                --, LineTo { lineWidth = 1, position = { x = 0, y = -2 } }
                --, LineTo { lineWidth = 1, position = { x = -1, y = -2 } }
                --
                --, LineTo { lineWidth = 1, position = { x = -1, y = -1 } }
                --, LineTo { lineWidth = 1, position = { x = 0, y = -1 } }
                --
                --, LineTo { lineWidth = 1, position = { x = 0, y = 0 } }
                --]
                --
                Generator.generate 1 rules axiom
                    |> Translator.translate Dictionary.default settings
                    |> Transformer.transform transformOptions
                    --|> Debug.log "translate"
                    --|> inspect Sequence.toList
                    |> Optimizer.simplify
                    --|> Debug.log "simplify"
                    --|> inspect Sequence.toList
                    |> Sequence.length
                    |> Expect.equal 17
        ]


defaultSettings : Settings
defaultSettings =
    Settings.default


transformOptions : Transformer.TransformOptions
transformOptions =
    let
        s =
            10
    in
    { windowPosition = { x = 0, y = -s }
    , windowSize = s
    , canvasSize = s
    }


inspect : (a -> b) -> a -> a
inspect f a =
    Debug.log (Debug.toString (f a)) a
