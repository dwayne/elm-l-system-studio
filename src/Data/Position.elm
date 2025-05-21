module Data.Position exposing (Position, translate)

import Data.Angle as Angle exposing (Angle)


type alias Position =
    { x : Float
    , y : Float
    }


translate : Float -> Angle -> Position -> Position
translate distance heading { x, y } =
    let
        ( sinAlpha, cosAlpha ) =
            Angle.sinAndCos heading

        dx =
            distance * cosAlpha

        dy =
            distance * sinAlpha
    in
    { x = x + dx, y = y + dy }
