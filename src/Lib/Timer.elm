module Lib.Timer exposing (Stats, Timer, getExpectedFps, new, step, toStats)


type Timer
    = Timer State


type alias State =
    { expectedFps : Float
    , interval : Float
    , totalCalls : Int
    , totalFrames : Int
    , totalElapsed : Float
    , elapsed : Float
    }


maxFps : Int
maxFps =
    60


new : Int -> Timer
new rawFps =
    let
        fps =
            toFloat (min maxFps (max 1 rawFps))

        interval =
            1000 / fps
    in
    Timer
        { expectedFps = fps
        , interval = interval
        , totalCalls = 0
        , totalFrames = 0
        , totalElapsed = 0
        , elapsed = 0
        }


getExpectedFps : Timer -> Float
getExpectedFps (Timer { expectedFps }) =
    expectedFps


step : Float -> (() -> a) -> Timer -> ( Timer, a )
step delta f (Timer state) =
    let
        currElapsed =
            state.elapsed + delta

        ( numFrames, elapsed ) =
            quotRem currElapsed state.interval

        totalCalls =
            state.totalCalls + 1

        totalFrames =
            state.totalFrames + numFrames

        totalElapsed =
            state.totalElapsed + delta
    in
    ( Timer
        { state
            | totalCalls = totalCalls
            , totalFrames = totalFrames
            , totalElapsed = totalElapsed
            , elapsed = elapsed
        }
    , f ()
    )


quotRem : Float -> Float -> ( Int, Float )
quotRem x y =
    quotRemHelper 0 x y


quotRemHelper : Int -> Float -> Float -> ( Int, Float )
quotRemHelper q x y =
    if x < y then
        ( q, x )

    else
        quotRemHelper (q + 1) (x - y) y


type alias Stats =
    { expectedFps : Float
    , interval : Float
    , totalCalls : Int
    , totalFrames : Int
    , totalElapsed : Float
    , elapsed : Float
    , actualFps : Float
    , cps : Float
    }


toStats : Timer -> Stats
toStats (Timer { expectedFps, interval, totalCalls, totalFrames, totalElapsed, elapsed }) =
    let
        ( actualFps, cps ) =
            if totalElapsed == 0 then
                ( 0, 0 )

            else
                let
                    factor =
                        1000 / totalElapsed
                in
                ( toFloat totalFrames * factor
                , toFloat totalCalls * factor
                )
    in
    { expectedFps = expectedFps
    , interval = interval
    , totalCalls = totalCalls
    , totalFrames = totalFrames
    , totalElapsed = totalElapsed
    , elapsed = elapsed
    , actualFps = actualFps
    , cps = cps
    }
