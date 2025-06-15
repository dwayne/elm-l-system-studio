module View.Preset exposing (ViewOptions, view)

import Data.Settings as Settings exposing (Settings)
import Dict exposing (Dict)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD


type alias Preset =
    { id : String
    , label : String
    , settings : Settings
    }


presets : List Preset
presets =
    [ { id = "kochCurve"
      , label = "Koch Curve"
      , settings = Settings.kochCurve
      }
    , { id = "tiles"
      , label = "Tiles"
      , settings = Settings.tiles
      }
    , { id = "tree"
      , label = "Tree"
      , settings = Settings.tree
      }
    , { id = "leaf"
      , label = "Leaf"
      , settings = Settings.leaf
      }
    , { id = "bush1"
      , label = "Bush 1"
      , settings = Settings.bush1
      }
    , { id = "bush2"
      , label = "Bush 2"
      , settings = Settings.bush2
      }
    , { id = "bush3"
      , label = "Bush 3"
      , settings = Settings.bush3
      }
    , { id = "bush4"
      , label = "Bush 4"
      , settings = Settings.bush4
      }
    , { id = "bush5"
      , label = "Bush 5"
      , settings = Settings.bush5
      }
    , { id = "crystal"
      , label = "Crrystal"
      , settings = Settings.crystal
      }
    , { id = "peanoCurve"
      , label = "Peano Curve"
      , settings = Settings.peanoCurve
      }
    , { id = "quadraticSnowflake"
      , label = "Quadratic Snowflake"
      , settings = Settings.quadraticSnowflake
      }
    , { id = "vonKochSnowflake"
      , label = "von Koch Snowflake"
      , settings = Settings.vonKochSnowflake
      }
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
            (List.map
                (\{ id, label } ->
                    H.option [ HA.value id ] [ H.text label ]
                )
                presets
            )
        ]



-- EVENTS


onInput : (Settings -> msg) -> H.Attribute msg
onInput toMsg =
    let
        decoder =
            HE.targetValue
                |> JD.andThen
                    (\s ->
                        case Dict.get s presetsAsDict of
                            Just { settings } ->
                                JD.succeed ( toMsg settings, True )

                            Nothing ->
                                JD.fail ("Unknown preset: " ++ s)
                    )
    in
    HE.stopPropagationOn "input" decoder


presetsAsDict : Dict String Preset
presetsAsDict =
    presets
        |> List.map (\preset -> ( preset.id, preset ))
        |> Dict.fromList
