module Data.Color exposing (Color, black, white)

import Color as Avh4Color


type Color
    = Color Avh4Color.Color


black : Color
black =
    Color <| Avh4Color.black


white : Color
white =
    Color <| Avh4Color.white
