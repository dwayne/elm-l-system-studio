module Data.Position exposing (Position, translate)

import Data.Angle as Angle exposing (Angle)


type alias Position =
    ( Float, Float )


translate : Float -> Angle -> Position -> Position
translate distance heading ( x, y ) =
    let
        alpha =
            Angle.toRadians heading

        dx =
            distance * cos alpha

        dy =
            distance * sin alpha
    in
    ( x + dx, y + dy )
