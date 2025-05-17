module Test.Data.Translator exposing (suite)

import Data.Dictionary as Dictionary
import Data.Settings as Settings
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
                    |> Translator.translate Dictionary.default Settings.default
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), LineTo ( 1, 0 ) ]
        , test "Example 2" <|
            \_ ->
                Sequence.fromString "f"
                    |> Translator.translate Dictionary.default Settings.default
                    |> Sequence.toList
                    |> Expect.equal [ MoveTo ( 0, 0 ), MoveTo ( 1, 0 ) ]
        ]
