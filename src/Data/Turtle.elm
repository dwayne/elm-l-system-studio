module Data.Turtle exposing (Turtle, new, turnLeft, turnRight, walk)

import Data.Angle as Angle exposing (Angle)
import Data.Position as Position exposing (Position)



--
-- Turtle coordinates:
--
--              +y
--              |
--              |
--              |
-- -x ----------|---------- +x
--              | (0,0)
--              |
--              |
--              -y
--
-- anti-clockwise = +ve (left turn)
--      clockwise = -ve (right turn)
--


type alias Turtle =
    { position : Position
    , heading : Angle
    }


new : Position -> Angle -> Turtle
new =
    Turtle


turnLeft : Angle -> Turtle -> Turtle
turnLeft angle turtle =
    { turtle | heading = Angle.add turtle.heading angle }


turnRight : Angle -> Turtle -> Turtle
turnRight angle turtle =
    { turtle | heading = Angle.sub turtle.heading angle }


walk : Float -> Turtle -> Turtle
walk distance turtle =
    { turtle | position = Position.translate distance turtle.heading turtle.position }
