module Data.Turtle exposing (Turtle, new, turn, walk)

import Data.Angle as Angle exposing (Angle)
import Data.Position as Position exposing (Position)


type alias Turtle =
    { position : Position
    , heading : Angle
    }


new : Position -> Angle -> Turtle
new =
    Turtle


turn : Angle -> Turtle -> Turtle
turn angle turtle =
    { turtle | heading = Angle.add angle turtle.heading }


walk : Float -> Turtle -> Turtle
walk distance turtle =
    { turtle | position = Position.translate distance turtle.heading turtle.position }
