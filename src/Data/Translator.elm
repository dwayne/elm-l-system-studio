module Data.Translator exposing (Instruction(..), TranslateOptions, default, translate)

import Data.Angle as Angle exposing (Angle)
import Data.Color as Color exposing (Color)
import Data.Dictionary as Dictionary exposing (Dictionary, Meaning(..))
import Data.Position exposing (Position)
import Data.Turtle as Turtle exposing (Turtle)
import Lib.Sequence as Sequence exposing (Sequence)


type alias TranslateOptions =
    { startPosition : Position
    , startHeading : Angle
    , lineLength : Float
    , lineLengthScaleFactor : Float
    , lineWidth : Float
    , lineWidthIncrement : Float
    , turningAngle : Angle
    , turningAngleIncrement : Angle
    , lineColor : Color
    , fillColor : Color
    }


default : TranslateOptions
default =
    { startPosition = { x = 0, y = 0 }
    , startHeading = Angle.zero
    , lineLength = 1
    , lineLengthScaleFactor = 1
    , lineWidth = 1
    , lineWidthIncrement = 0
    , turningAngle = Angle.zero
    , turningAngleIncrement = Angle.zero
    , lineColor = Color.black
    , fillColor = Color.white
    }


type Instruction
    = MoveTo Position
    | Line
        { start : Position
        , end : Position
        , lineWidth : Float
        }


translate : Dictionary -> TranslateOptions -> Sequence Char -> Sequence Instruction
translate dictionary options chars =
    let
        startState =
            initState options
    in
    Sequence.filterMapWithState
        (\ch ( state, stack ) ->
            case Dictionary.find ch dictionary of
                Just meaning ->
                    translateMeaning options meaning state stack

                Nothing ->
                    ( Nothing, ( state, stack ) )
        )
        ( startState, [] )
        chars


translateMeaning : TranslateOptions -> Meaning -> State -> List State -> ( Maybe Instruction, ( State, List State ) )
translateMeaning options meaning state stack =
    case meaning of
        Move ->
            let
                turtle =
                    Turtle.walk state.lineLength state.turtle
            in
            ( Just (Line { start = state.turtle.position, end = turtle.position, lineWidth = state.lineWidth })
            , ( { state | turtle = turtle }, stack )
            )

        MoveWithoutDrawing ->
            let
                turtle =
                    Turtle.walk state.lineLength state.turtle
            in
            ( Just (MoveTo turtle.position)
            , ( { state | turtle = turtle }, stack )
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
            , ( { state | turtle = turn state.turningAngle state.turtle }, stack )
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
            , ( { state | turtle = turn state.turningAngle state.turtle }, stack )
            )

        ReverseDirection ->
            ( Nothing
            , ( { state | turtle = Turtle.turnLeft Angle.straight state.turtle }, stack )
            )

        Push ->
            ( Nothing
            , ( state, state :: stack )
            )

        Pop ->
            case stack of
                [] ->
                    ( Nothing, ( state, [] ) )

                prevState :: restStack ->
                    ( Just (MoveTo prevState.turtle.position)
                    , ( prevState, restStack )
                    )

        IncrementLineWidth ->
            ( Nothing
            , ( { state | lineWidth = state.lineWidth + options.lineWidthIncrement }, stack )
            )

        DecrementLineWidth ->
            ( Nothing
            , ( { state | lineWidth = state.lineWidth - options.lineWidthIncrement }, stack )
            )

        DrawDot ->
            ( Nothing, ( state, stack ) )

        OpenPolygon ->
            ( Nothing, ( state, stack ) )

        ClosePolygon ->
            ( Nothing, ( state, stack ) )

        MultiplyLineLength ->
            ( Nothing
            , ( { state | lineLength = state.lineLength * options.lineLengthScaleFactor }, stack )
            )

        DivideLineLength ->
            ( Nothing
            , ( { state
                    | lineLength =
                        if options.lineLengthScaleFactor == 0 then
                            0

                        else
                            state.lineLength / options.lineLengthScaleFactor
                }
              , stack
              )
            )

        SwapPlusMinus ->
            ( Nothing
            , ( { state | swapPlusMinus = not state.swapPlusMinus }, stack )
            )

        IncrementTurningAngle ->
            ( Nothing
            , ( { state | turningAngle = Angle.add state.turningAngle options.turningAngleIncrement }, stack )
            )

        DecrementTurningAngle ->
            ( Nothing
            , ( { state | turningAngle = Angle.sub state.turningAngle options.turningAngleIncrement }, stack )
            )



-- STATE


type alias State =
    { turtle : Turtle
    , lineLength : Float
    , lineWidth : Float
    , turningAngle : Angle
    , swapPlusMinus : Bool
    }


initState : TranslateOptions -> State
initState options =
    { turtle = Turtle.new options.startPosition options.startHeading
    , lineLength = options.lineLength
    , lineWidth = options.lineWidth
    , turningAngle = options.turningAngle
    , swapPlusMinus = False
    }
