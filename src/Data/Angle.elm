module Data.Angle exposing (Angle, add, fromDegrees, negate, sub, toRadians, zero)


type Angle
    = Deg Float


zero : Angle
zero =
    Deg 0


fromDegrees : Float -> Angle
fromDegrees =
    Deg << normalize


negate : Angle -> Angle
negate (Deg a) =
    fromDegrees -a


add : Angle -> Angle -> Angle
add (Deg a) (Deg b) =
    fromDegrees (a + b)


sub : Angle -> Angle -> Angle
sub (Deg a) (Deg b) =
    fromDegrees (a - b)


toRadians : Angle -> Float
toRadians (Deg angle) =
    degrees angle


normalize : Float -> Float
normalize x =
    if x < 0 then
        normalize (x + 360)

    else if x < 360 then
        x

    else
        normalize (x - 360)
