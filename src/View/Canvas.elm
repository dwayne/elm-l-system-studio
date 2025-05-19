module View.Canvas exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA


type alias ViewOptions =
    { id : String
    , width : Int
    , height : Int
    }


view : ViewOptions -> H.Html msg
view { id, width, height } =
    H.canvas
        [ HA.id id
        , HA.class "canvas"
        , HA.width width
        , HA.height height
        ]
        [ H.text "Canvas not supported." ]
