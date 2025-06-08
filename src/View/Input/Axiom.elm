module View.Input.Axiom exposing (ViewOptions, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE


type alias ViewOptions msg =
    { axiom : String
    , onInput : String -> msg
    }


view : ViewOptions msg -> H.Html msg
view { axiom, onInput } =
    H.p []
        [ H.label [ HA.for "axiom" ] [ H.text "Axiom" ]
        , H.span [] [ H.text ": " ]
        , H.input
            [ HA.id "axiom"
            , HA.type_ "text"
            , HA.placeholder "F+F+F+F"
            , HA.value axiom
            , HE.onInput onInput
            ]
            []
        ]
