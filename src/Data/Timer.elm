module Data.Timer exposing (Timer, new, step, toInfo)


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


new : Int -> Timer
new rawFps =
    let
        fps =
            -- 1 <= fps <= 240
            toFloat (min 240 (max 1 rawFps))

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


type alias Info =
    { expectedFps : Float
    , interval : Float
    , totalCalls : Int
    , totalFrames : Int
    , totalElapsed : Float
    , elapsed : Float
    , actualFps : Float
    , cps : Float
    }


toInfo : Timer -> Info
toInfo (Timer state) =
    let
        totalElapsed =
            state.totalElapsed

        ( actualFps, cps ) =
            if totalElapsed == 0 then
                ( 0, 0 )

            else
                let
                    factor =
                        1000 / totalElapsed
                in
                ( toFloat state.totalFrames * factor
                , toFloat state.totalCalls * factor
                )
    in
    { expectedFps = state.expectedFps
    , interval = state.interval
    , totalCalls = state.totalCalls
    , totalFrames = state.totalFrames
    , totalElapsed = totalElapsed
    , elapsed = state.elapsed
    , actualFps = actualFps
    , cps = cps
    }
