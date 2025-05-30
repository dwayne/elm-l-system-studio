port module Data.Renderer exposing (Msg, Renderer, init, subscriptions, toInfo, update)

import Browser.Events as BE
import Data.Instruction exposing (Instruction(..))
import Data.Position exposing (Position)
import Data.Timer as Timer exposing (Timer)
import Json.Encode as JE
import Lib.Sequence as Sequence exposing (Sequence)


type Renderer
    = Renderer State


type alias State =
    { timer : Timer
    , ipfAsInt : Int
    , ipfAsFloat : Float
    , instructions : Sequence Instruction
    , totalInstructions : Int
    , commands : List JE.Value
    }


type alias InitOptions =
    { fps : Int
    , ipf : Int
    , instructions : Sequence Instruction
    }


init : InitOptions -> Renderer
init { fps, ipf, instructions } =
    Renderer
        { timer = Timer.new fps
        , ipfAsInt = ipf
        , ipfAsFloat = toFloat ipf
        , instructions = instructions
        , totalInstructions = 0
        , commands = []
        }


type Msg
    = GotAnimationFrame Float


type alias UpdateOptions =
    { renderingOptions : RenderingOptions
    }


type alias RenderingOptions =
    { windowPosition : Position
    , windowSize : Float
    , canvasSize : Float
    }


update : UpdateOptions -> Msg -> Renderer -> ( Renderer, Cmd msg )
update { renderingOptions } msg (Renderer state) =
    case msg of
        GotAnimationFrame delta ->
            let
                ( timer, ( ( instructions, cmd ), numInstructions ) ) =
                    Timer.step
                        delta
                        (\_ ->
                            let
                                { expectedFps } =
                                    Timer.toInfo state.timer

                                expectedNumInstructions =
                                    ceiling (expectedFps * state.ipfAsFloat * delta * 0.001)

                                n =
                                    max 1 (modBy state.ipfAsInt expectedNumInstructions)
                            in
                            ( render renderingOptions n state.instructions, n )
                        )
                        state.timer

                totalInstructions =
                    state.totalInstructions + numInstructions
            in
            ( Renderer { state | timer = timer, instructions = instructions, totalInstructions = totalInstructions }
            , cmd
            )


render : RenderingOptions -> Int -> Sequence Instruction -> ( Sequence Instruction, Cmd msg )
render =
    renderHelper []


renderHelper : List JE.Value -> RenderingOptions -> Int -> Sequence Instruction -> ( Sequence Instruction, Cmd msg )
renderHelper values renderingOptions atMost instructions =
    if atMost > 0 then
        case Sequence.uncons instructions of
            Just ( instruction, restInstructions ) ->
                renderHelper
                    (encode renderingOptions instruction :: values)
                    renderingOptions
                    (atMost - 1)
                    restInstructions

            Nothing ->
                ( instructions
                , toCmd values
                )

    else
        ( instructions
        , toCmd values
        )


toCmd : List JE.Value -> Cmd msg
toCmd values =
    if values == [] then
        Cmd.none

    else
        values
            |> List.reverse
            |> JE.list identity
            |> drawBatch


encode : RenderingOptions -> Instruction -> JE.Value
encode renderingOptions instruction =
    case instruction of
        MoveTo position ->
            let
                { x, y } =
                    toCanvasCoords renderingOptions position
            in
            JE.object
                [ ( "function", JE.string "moveTo" )
                , ( "x", JE.int x )
                , ( "y", JE.int y )
                ]

        LineTo { position, lineWidth } ->
            let
                { x, y } =
                    toCanvasCoords renderingOptions position
            in
            JE.object
                [ ( "function", JE.string "lineTo" )
                , ( "x", JE.int x )
                , ( "y", JE.int y )
                , ( "lineWidth", JE.float lineWidth )
                ]

        _ ->
            JE.int 0


type alias Coords =
    { x : Int
    , y : Int
    }


toCanvasCoords : RenderingOptions -> Position -> Coords
toCanvasCoords { windowPosition, windowSize, canvasSize } position =
    let
        x0 =
            windowPosition.x

        y0 =
            windowPosition.y

        s =
            windowSize

        l =
            canvasSize

        xw =
            position.x

        yw =
            position.y
    in
    { x = round ((xw - x0) * l / s)
    , y = round (l - (yw - y0) * l / s)
    }


port drawBatch : JE.Value -> Cmd msg


subscriptions : (Msg -> msg) -> Renderer -> Sub msg
subscriptions onChange (Renderer { instructions }) =
    if Sequence.isEmpty instructions then
        Sub.none

    else
        BE.onAnimationFrameDelta (onChange << GotAnimationFrame)


type alias Info =
    { expectedFps : Float
    , actualFps : Float
    , cps : Float
    , ips : Float
    , commands : List JE.Value
    }


toInfo : Renderer -> Info
toInfo (Renderer { timer, totalInstructions, commands }) =
    let
        { expectedFps, totalElapsed, actualFps, cps } =
            Timer.toInfo timer
    in
    { expectedFps = expectedFps
    , actualFps = actualFps
    , cps = cps
    , ips =
        if totalElapsed == 0 then
            0

        else
            1000 * toFloat totalInstructions / totalElapsed
    , commands = commands
    }
