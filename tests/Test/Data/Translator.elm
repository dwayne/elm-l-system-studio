module Test.Data.Translator exposing (suite)

import Data.Angle as Angle
import Data.Dictionary as Dictionary
import Data.Settings as Settings exposing (Settings)
import Data.Translator as Translator exposing (Instruction(..))
import Expect
import Lib.Sequence as Sequence
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Data.Translator"
        [ test "Example 1" <|
            \_ ->
                Sequence.fromString "F"
                    |> Translator.translate Dictionary.default defaultSettings
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), LineTo ( 1, 0 ) ]
        , test "Example 2" <|
            \_ ->
                Sequence.fromString "f"
                    |> Translator.translate Dictionary.default defaultSettings
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), MoveTo ( 1, 0 ) ]
        , test "Example 3" <|
            \_ ->
                let
                    settings =
                        { defaultSettings | turningAngle = Angle.fromDegrees 90 }

                    alpha =
                        degrees 270
                in
                Sequence.fromString "+F"
                    |> Translator.translate Dictionary.default settings
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), LineTo ( cos alpha, sin alpha ) ]
        , test "Example 4" <|
            \_ ->
                let
                    settings =
                        { defaultSettings | turningAngle = Angle.fromDegrees 90 }

                    alpha =
                        degrees 90
                in
                Sequence.fromString "&+F"
                    |> Translator.translate Dictionary.default settings
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), LineTo ( cos alpha, sin alpha ) ]
        , test "Example 5" <|
            \_ ->
                let
                    settings =
                        { defaultSettings | turningAngle = Angle.fromDegrees 90 }

                    alpha =
                        degrees 90
                in
                Sequence.fromString "-F"
                    |> Translator.translate Dictionary.default settings
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), LineTo ( cos alpha, sin alpha ) ]
        , test "Example 6" <|
            \_ ->
                let
                    settings =
                        { defaultSettings | turningAngle = Angle.fromDegrees 90 }

                    alpha =
                        degrees 270
                in
                Sequence.fromString "&-F"
                    |> Translator.translate Dictionary.default settings
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), LineTo ( cos alpha, sin alpha ) ]
        ]


defaultSettings : Settings
defaultSettings =
    Settings.default
