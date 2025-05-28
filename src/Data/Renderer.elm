port module Data.Renderer exposing (Msg, Renderer, init, subscriptions, toInfo, update)

import Browser.Events as BE
import Data.Instruction as Instruction exposing (Instruction)
import Data.Optimizer exposing (SubPath)
import Data.Timer as Timer exposing (Timer)
import Json.Encode as JE
import Lib.Sequence as Sequence exposing (Sequence)


type Renderer
    = Renderer State


type alias State =
    { timer : Timer
    , spfAsInt : Int
    , spfAsFloat : Float
    , subPaths : Sequence SubPath
    , totalSubPaths : Int
    , commands : List JE.Value
    }


type alias InitOptions =
    { fps : Int
    , spf : Int
    , subPaths : Sequence SubPath
    }


init : InitOptions -> Renderer
init { fps, spf, subPaths } =
    Renderer
        { timer = Timer.new fps
        , spfAsInt = spf
        , spfAsFloat = toFloat spf
        , subPaths = subPaths
        , totalSubPaths = 0
        , commands = []
        }


type Msg
    = GotAnimationFrame Float


update : (Msg -> msg) -> Msg -> Renderer -> ( Renderer, Cmd msg )
update onChange msg (Renderer state) =
    case msg of
        GotAnimationFrame delta ->
            let
                ( timer, ( ( subPaths, cmd ), numSubPaths ) ) =
                    Timer.step
                        delta
                        (\_ ->
                            let
                                { expectedFps } =
                                    Timer.toInfo state.timer

                                expectedNumSubPaths =
                                    ceiling (expectedFps * state.spfAsFloat * delta * 0.001)

                                n =
                                    max 1 (modBy state.spfAsInt expectedNumSubPaths)
                            in
                            ( render n state.subPaths, n )
                        )
                        state.timer

                totalSubPaths =
                    state.totalSubPaths + numSubPaths
            in
            ( Renderer { state | timer = timer, subPaths = subPaths, totalSubPaths = totalSubPaths }
            , cmd
            )


render : Int -> Sequence SubPath -> ( Sequence SubPath, Cmd msg )
render =
    renderHelper []


renderHelper : List JE.Value -> Int -> Sequence SubPath -> ( Sequence SubPath, Cmd msg )
renderHelper values atMost subPaths =
    if atMost > 0 then
        case Sequence.uncons subPaths of
            Just ( subPath, restSubPaths ) ->
                renderHelper
                    (encode subPath :: values)
                    (atMost - 1)
                    restSubPaths

            Nothing ->
                ( subPaths
                , toCmd values
                )

    else
        ( subPaths
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


encode : SubPath -> JE.Value
encode =
    JE.list Instruction.encode


port drawBatch : JE.Value -> Cmd msg


subscriptions : (Msg -> msg) -> Renderer -> Sub msg
subscriptions onChange (Renderer { subPaths }) =
    if Sequence.isEmpty subPaths then
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
toInfo (Renderer { timer, totalSubPaths, commands }) =
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
            1000 * toFloat totalSubPaths / totalElapsed
    , commands = commands
    }
