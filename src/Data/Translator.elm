module Data.Translator exposing (Instruction(..), translate)

import Data.Dictionary as Dictionary exposing (Dictionary, Meaning(..))
import Data.Position exposing (Position)
import Data.Settings exposing (Settings)
import Data.Turtle as Turtle exposing (Turtle)
import Lib.Sequence as Sequence exposing (Sequence)


type Instruction
    = Nop
    | MoveTo Position
    | LineTo Position


translate : Dictionary -> Settings -> Sequence Char -> Sequence Instruction
translate dictionary settings chars =
    let
        startState =
            initState settings

        head =
            MoveTo startState.turtle.position

        tail =
            Sequence.mapWithState
                (\ch state ->
                    case Dictionary.find ch dictionary of
                        Just meaning ->
                            translateMeaning settings meaning state

                        Nothing ->
                            ( Nop, state )
                )
                startState
                chars
    in
    Sequence.cons head tail


translateMeaning : Settings -> Meaning -> State -> ( Instruction, State )
translateMeaning settings meaning state =
    case meaning of
        Move ->
            let
                turtle =
                    Turtle.walk settings.lineLength state.turtle
            in
            ( LineTo turtle.position
            , { state | turtle = turtle }
            )

        MoveWithoutDrawing ->
            let
                turtle =
                    Turtle.walk settings.lineLength state.turtle
            in
            ( MoveTo turtle.position
            , { state | turtle = turtle }
            )

        _ ->
            ( Nop, state )



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
