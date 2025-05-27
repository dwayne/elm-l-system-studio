module View.Canvas exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA
import Json.Encode as JE


type alias ViewOptions msg =
    { width : Int
    , height : Int
    , commands : List JE.Value
    , attrs : List (H.Attribute msg)
    }


view : ViewOptions msg -> H.Html msg
view { width, height, commands, attrs } =
    H.node "elm-canvas"
        (attrs
            ++ [ HA.width width
               , HA.height height
               , HA.property "commands" (JE.list identity commands)
               ]
        )
        [ H.text "Canvas not supported." ]
