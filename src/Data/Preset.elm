module Data.Preset exposing (Preset, default, fromId, presets)

import Data.Settings as Settings exposing (Settings)
import Dict exposing (Dict)


type alias Preset =
    { id : String
    , name : String
    , settings : Settings
    }


default : Preset
default =
    { id = "kochCurve"
    , name = "Koch Curve"
    , settings = Settings.kochCurve
    }


presets : List Preset
presets =
    [ default
    , { id = "tiles"
      , name = "Tiles"
      , settings = Settings.tiles
      }
    , { id = "tree"
      , name = "Tree"
      , settings = Settings.tree
      }
    , { id = "leaf"
      , name = "Leaf"
      , settings = Settings.leaf
      }
    , { id = "bush1"
      , name = "Bush 1"
      , settings = Settings.bush1
      }
    , { id = "bush2"
      , name = "Bush 2"
      , settings = Settings.bush2
      }
    , { id = "bush3"
      , name = "Bush 3"
      , settings = Settings.bush3
      }
    , { id = "bush4"
      , name = "Bush 4"
      , settings = Settings.bush4
      }
    , { id = "bush5"
      , name = "Bush 5"
      , settings = Settings.bush5
      }
    , { id = "crystal"
      , name = "Crystal"
      , settings = Settings.crystal
      }
    , { id = "peanoCurve"
      , name = "Peano Curve"
      , settings = Settings.peanoCurve
      }
    , { id = "quadraticSnowflake"
      , name = "Quadratic Snowflake"
      , settings = Settings.quadraticSnowflake
      }
    , { id = "vonKochSnowflake"
      , name = "von Koch Snowflake"
      , settings = Settings.vonKochSnowflake
      }
    ]


fromId : String -> Maybe Preset
fromId id =
    Dict.get id presetsAsDict


presetsAsDict : Dict String Preset
presetsAsDict =
    presets
        |> List.map (\preset -> ( preset.id, preset ))
        |> Dict.fromList
