module Canvas exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA
import Html.Keyed as HK
import Json.Encode as JE
import Line exposing (Line)


type alias ViewOptions =
    { width : Int
    , height : Int
    , lines : List Line
    }


view : ViewOptions -> H.Html msg
view { width, height, lines } =
    HK.node "elm-canvas"
        [ commands lines ]
        [ ( "canvas"
          , H.canvas
                [ HA.width width
                , HA.height height
                , HA.style "border" "1px solid black"
                ]
                [ H.text "Canvas not supported." ]
          )
        ]


commands : List Line -> H.Attribute msg
commands =
    HA.property "commands" << JE.list Line.toValue
