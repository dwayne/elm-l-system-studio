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
                    |> Expect.equal [ MoveTo ( 0, 0 ), LineTo { position = ( 1, 0 ), lineWidth = 1 } ]
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
                Sequence.fromString "+f"
                    |> Translator.translate Dictionary.default settings
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), MoveTo ( cos alpha, sin alpha ) ]
        , test "Example 4" <|
            \_ ->
                let
                    settings =
                        { defaultSettings | turningAngle = Angle.fromDegrees 90 }

                    alpha =
                        degrees 90
                in
                Sequence.fromString "&+f"
                    |> Translator.translate Dictionary.default settings
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), MoveTo ( cos alpha, sin alpha ) ]
        , test "Example 5" <|
            \_ ->
                let
                    settings =
                        { defaultSettings | turningAngle = Angle.fromDegrees 90 }

                    alpha =
                        degrees 90
                in
                Sequence.fromString "-f"
                    |> Translator.translate Dictionary.default settings
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), MoveTo ( cos alpha, sin alpha ) ]
        , test "Example 6" <|
            \_ ->
                let
                    settings =
                        { defaultSettings | turningAngle = Angle.fromDegrees 90 }

                    alpha =
                        degrees 270
                in
                Sequence.fromString "&-f"
                    |> Translator.translate Dictionary.default settings
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), MoveTo ( cos alpha, sin alpha ) ]
        , test "Example 7" <|
            \_ ->
                let
                    settings =
                        { defaultSettings | turningAngle = Angle.fromDegrees 45 }
                in
                Sequence.fromString "----|f"
                    |> Translator.translate Dictionary.default settings
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), MoveTo ( 1, 0 ) ]
        , test "Example 8" <|
            \_ ->
                let
                    settings =
                        { defaultSettings | turningAngle = Angle.fromDegrees 90 }
                in
                Sequence.fromString "[+]f"
                    |> Translator.translate Dictionary.default settings
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), MoveTo ( 1, 0 ) ]
        , test "Example 9" <|
            \_ ->
                let
                    settings =
                        { defaultSettings | lineWidthIncrement = 1 }
                in
                Sequence.fromString "###!F"
                    |> Translator.translate Dictionary.default settings
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), LineTo { position = ( 1, 0 ), lineWidth = 3 } ]
        , test "Example 10" <|
            \_ ->
                let
                    settings =
                        { defaultSettings
                            | turningAngle = Angle.fromDegrees 90
                            , turningAngleIncrement = Angle.fromDegrees 45
                        }
                in
                Sequence.fromString "))))))()()+f"
                    |> Translator.translate Dictionary.default settings
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), MoveTo ( 1, 0 ) ]
        , test "Example 11" <|
            \_ ->
                let
                    settings =
                        { defaultSettings | lineLengthScaleFactor = 5 }
                in
                Sequence.fromString ">ff<f"
                    |> Translator.translate Dictionary.default settings
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), MoveTo ( 5, 0 ), MoveTo ( 10, 0 ), MoveTo ( 11, 0 ) ]
        ]


defaultSettings : Settings
defaultSettings =
    Settings.default
