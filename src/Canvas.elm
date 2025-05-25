module Canvas exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA
import Json.Encode as JE
import Line exposing (Line)


type alias ViewOptions msg =
    { width : Int
    , height : Int
    , lines : List Line
    , attrs : List (H.Attribute msg)
    }


view : ViewOptions msg -> H.Html msg
view { width, height, lines, attrs } =
    H.node "elm-canvas"
        (attrs
            ++ [ HA.width width
               , HA.height height
               , HA.property "commands" (JE.list Line.toValue lines)
               ]
        )
        [ H.text "Canvas not supported." ]
