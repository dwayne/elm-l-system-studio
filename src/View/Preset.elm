module View.Preset exposing (ViewOptions, view)

import Data.Settings as Settings exposing (Settings)
import Dict exposing (Dict)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD



-- CONSTANTS


presets : Dict String Settings
presets =
    Dict.fromList
        [ ( "kochCurve", Settings.kochCurve )
        , ( "tiles", Settings.tiles )
        , ( "tree", Settings.tree )
        , ( "leaf", Settings.leaf )
        , ( "crystal", Settings.crystal )
        , ( "peanoCurve", Settings.peanoCurve )
        , ( "quadraticSnowflake", Settings.quadraticSnowflake )
        , ( "vonKochSnowflake", Settings.vonKochSnowflake )
        ]



-- VIEW


type alias ViewOptions msg =
    { onSettings : Settings -> msg
    }


view : ViewOptions msg -> H.Html msg
view { onSettings } =
    H.p []
        [ H.label [ HA.for "preset" ] [ H.text "Preset" ]
        , H.text ": "
        , H.select
            [ HA.id "preset"
            , onInput onSettings
            ]
            [ H.option [ HA.value "kochCurve" ] [ H.text "Koch Curve" ]
            , H.option [ HA.value "tiles" ] [ H.text "Tiles" ]
            , H.option [ HA.value "tree" ] [ H.text "Tree" ]
            , H.option [ HA.value "leaf" ] [ H.text "Leaf" ]
            , H.option [ HA.value "crystal" ] [ H.text "Crystal" ]
            , H.option [ HA.value "peanoCurve" ] [ H.text "Peano Curve" ]
            , H.option [ HA.value "quadraticSnowflake" ] [ H.text "Quadratic Snowflake" ]
            , H.option [ HA.value "vonKochSnowflake" ] [ H.text "von Koch Snowflake" ]
            ]
        ]



-- EVENTS


onInput : (Settings -> msg) -> H.Attribute msg
onInput toMsg =
    let
        decoder =
            HE.targetValue
                |> JD.andThen
                    (\s ->
                        case Dict.get s presets of
                            Just settings ->
                                JD.succeed ( toMsg settings, True )

                            Nothing ->
                                JD.fail ("Unknown preset: " ++ s)
                    )
    in
    HE.stopPropagationOn "input" decoder
