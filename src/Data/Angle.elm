module Data.Angle exposing
    ( Angle
    , add
    , fromDegrees
    , right
    , sinAndCos
    , straight
    , sub
    , toDegrees
    , zero
    )


type Angle
    = Deg Float


zero : Angle
zero =
    Deg 0


right : Angle
right =
    Deg 90


straight : Angle
straight =
    Deg 180


fromDegrees : Float -> Angle
fromDegrees =
    Deg << normalize


add : Angle -> Angle -> Angle
add (Deg a) (Deg b) =
    fromDegrees (a + b)


sub : Angle -> Angle -> Angle
sub (Deg a) (Deg b) =
    fromDegrees (a - b)


sinAndCos : Angle -> ( Float, Float )
sinAndCos (Deg angle) =
    if angle == 0 then
        ( 0, 1 )

    else if angle == 90 then
        ( 1, 0 )

    else if angle == 180 then
        ( 0, -1 )

    else if angle == 270 then
        ( -1, 0 )

    else
        let
            alpha =
                degrees angle
        in
        ( sin alpha
        , cos alpha
        )


toDegrees : Angle -> Float
toDegrees (Deg angle) =
    angle


normalize : Float -> Float
normalize x =
    if x < 0 then
        normalize (x + 360)

    else if x < 360 then
        x

    else
        normalize (x - 360)
