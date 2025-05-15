module Test.LSystem exposing (suite)

import Expect
import LSystem
import Sequence
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "LSystem"
        [ test "Example 1" <|
            \_ ->
                LSystem.generate 1 [ ( 'F', "F+F-F-FF+F+F-F" ) ] "F+F+F+F"
                    |> Sequence.toList
                    |> String.fromList
                    |> Expect.equal "F+F-F-FF+F+F-F+F+F-F-FF+F+F-F+F+F-F-FF+F+F-F+F+F-F-FF+F+F-F"
        ]
