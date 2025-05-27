module Data.Translator exposing (translate)

import Data.Angle as Angle exposing (Angle)
import Data.Dictionary as Dictionary exposing (Dictionary, Meaning(..))
import Data.Instruction exposing (Instruction(..))
import Data.Settings exposing (Settings)
import Data.Turtle as Turtle exposing (Turtle)
import Lib.Sequence as Sequence exposing (Sequence)


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
    Sequence.cons head (Sequence.cons head tail)


translateMeaning : Settings -> Meaning -> State -> ( Maybe Instruction, State )
translateMeaning settings meaning state =
    case meaning of
        Move ->
            let
                turtle =
                    Turtle.walk state.lineLength state.turtle
            in
            ( Just (LineTo { position = turtle.position, lineWidth = state.lineWidth })
            , { state | turtle = turtle }
            )

        MoveWithoutDrawing ->
            let
                turtle =
                    Turtle.walk state.lineLength state.turtle
            in
            ( Just (MoveTo turtle.position)
            , { state | turtle = turtle }
            )

        TurnLeft ->
            let
                turn =
                    if state.swapPlusMinus then
                        Turtle.turnRight

                    else
                        Turtle.turnLeft
            in
            ( Nothing
            , { state | turtle = turn state.turningAngle state.turtle }
            )

        TurnRight ->
            let
                turn =
                    if state.swapPlusMinus then
                        Turtle.turnLeft

                    else
                        Turtle.turnRight
            in
            ( Nothing
            , { state | turtle = turn state.turningAngle state.turtle }
            )

        ReverseDirection ->
            ( Nothing
            , { state | turtle = Turtle.turnLeft Angle.straight state.turtle }
            )

        Push ->
            ( Nothing
            , { state | stack = state.turtle :: state.stack }
            )

        Pop ->
            case state.stack of
                [] ->
                    ( Nothing, state )

                turtle :: restStack ->
                    ( Just (MoveTo turtle.position)
                    , { state | turtle = turtle, stack = restStack }
                    )

        IncrementLineWidth ->
            ( Nothing
            , { state | lineWidth = state.lineWidth + settings.lineWidthIncrement }
            )

        DecrementLineWidth ->
            ( Nothing
            , { state | lineWidth = state.lineWidth - settings.lineWidthIncrement }
            )

        DrawDot ->
            Debug.todo "Implement and test DrawDot"

        OpenPolygon ->
            Debug.todo "Implement and test OpenPolygon"

        ClosePolygon ->
            Debug.todo "Implement and test ClosePolygon"

        MultiplyLineLength ->
            ( Nothing
            , { state | lineLength = state.lineLength * settings.lineLengthScaleFactor }
            )

        DivideLineLength ->
            ( Nothing
            , { state
                | lineLength =
                    if settings.lineLengthScaleFactor == 0 then
                        0

                    else
                        state.lineLength / settings.lineLengthScaleFactor
              }
            )

        SwapPlusMinus ->
            ( Nothing
            , { state | swapPlusMinus = not state.swapPlusMinus }
            )

        IncrementTurningAngle ->
            ( Nothing
            , { state | turningAngle = Angle.add state.turningAngle settings.turningAngleIncrement }
            )

        DecrementTurningAngle ->
            ( Nothing
            , { state | turningAngle = Angle.sub state.turningAngle settings.turningAngleIncrement }
            )



-- STATE


type alias State =
    { turtle : Turtle
    , stack : List Turtle
    , lineLength : Float
    , lineWidth : Float
    , turningAngle : Angle
    , swapPlusMinus : Bool
    }


initState : Settings -> State
initState settings =
    { turtle = Turtle.new settings.startPosition settings.startHeading
    , stack = []
    , lineLength = settings.lineLength
    , lineWidth = settings.lineWidth
    , turningAngle = settings.turningAngle
    , swapPlusMinus = False
    }
