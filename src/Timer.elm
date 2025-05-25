module Timer exposing (Timer, actualFps, new, step)


type Timer
    = Timer
        { expectedFps : Int
        , interval : Float
        , totalFrames : Int
        , totalElapsed : Float
        , elapsed : Float
        }


new : Int -> Timer
new rawFps =
    let
        fps =
            max 1 rawFps

        interval =
            1000 / toFloat fps
    in
    Timer
        { expectedFps = fps
        , interval = interval
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

        totalFrames =
            state.totalFrames + numFrames

        totalElapsed =
            state.totalElapsed + delta
    in
    ( Timer
        { state
            | totalFrames = totalFrames
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


actualFps : Timer -> Float
actualFps (Timer { totalFrames, totalElapsed }) =
    if totalElapsed == 0 then
        0

    else
        1000 * toFloat totalFrames / totalElapsed
