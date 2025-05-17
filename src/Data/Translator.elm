module Data.Translator exposing (Instruction(..), translate)

import Data.Angle as Angle
import Data.Dictionary as Dictionary exposing (Dictionary, Meaning(..))
import Data.Position exposing (Position)
import Data.Settings exposing (Settings)
import Data.Turtle as Turtle exposing (Turtle)
import Lib.Sequence as Sequence exposing (Sequence)


type Instruction
    = MoveTo Position
    | LineTo Position


translate : Dictionary -> Settings -> Sequence Char -> Sequence Instruction
translate dictionary settings chars =
    let
        startState =
            initState settings

        head =
            MoveTo startState.turtle.position

        tail =
            Sequence.filterMapWithState
                (\ch state ->
                    case Dictionary.find ch dictionary of
                        Just meaning ->
                            translateMeaning settings meaning state

                        Nothing ->
                            ( Nothing, state )
                )
                startState
                chars
    in
    Sequence.cons head tail


translateMeaning : Settings -> Meaning -> State -> ( Maybe Instruction, State )
translateMeaning settings meaning state =
    case meaning of
        Move ->
            let
                turtle =
                    Turtle.walk settings.lineLength state.turtle
            in
            ( Just <| LineTo turtle.position
            , { state | turtle = turtle }
            )

        MoveWithoutDrawing ->
            let
                turtle =
                    Turtle.walk settings.lineLength state.turtle
            in
            ( Just <| MoveTo turtle.position
            , { state | turtle = turtle }
            )

        TurnLeft ->
            let
                angle =
                    if state.swapPlusMinus then
                        settings.turningAngle

                    else
                        Angle.negate settings.turningAngle

                turtle =
                    Turtle.turn angle state.turtle
            in
            ( Nothing
            , { state | turtle = turtle }
            )

        TurnRight ->
            let
                angle =
                    if state.swapPlusMinus then
                        Angle.negate settings.turningAngle

                    else
                        settings.turningAngle

                turtle =
                    Turtle.turn angle state.turtle
            in
            ( Nothing
            , { state | turtle = turtle }
            )

        SwapPlusMinus ->
            ( Nothing
            , { state | swapPlusMinus = not state.swapPlusMinus }
            )

        _ ->
            ( Nothing, state )



-- STATE


type alias State =
    { turtle : Turtle
    , stack : List Turtle
    , swapPlusMinus : Bool
    }


initState : Settings -> State
initState settings =
    { turtle = Turtle.new settings.startPosition settings.startHeading
    , stack = []
    , swapPlusMinus = False
    }
