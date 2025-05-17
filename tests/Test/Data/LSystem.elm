module Test.Data.LSystem exposing (suite)

import Data.LSystem as LSystem
import Expect
import Lib.Sequence as Sequence
import Test exposing (Test, describe, test)


suite : Test
suite =
    let
        rules =
            [ ( 'F', "F+F-F-FF+F+F-F" ) ]

        axiom =
            "F+F+F+F"
    in
    describe "Data.LSystem"
        [ test "Example 1" <|
            \_ ->
                LSystem.generate 1 rules axiom
                    |> Sequence.toList
                    |> String.fromList
                    |> Expect.equal "F+F-F-FF+F+F-F+F+F-F-FF+F+F-F+F+F-F-FF+F+F-F+F+F-F-FF+F+F-F"
        , test "Example 2" <|
            \_ ->
                LSystem.generate 6 rules axiom
                    |> Sequence.length
                    |> Expect.equal 1947355
        ]
