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
    , { id = "sticks"
      , name = "Sticks"
      , settings = Settings.sticks
      }
    , { id = "algae1"
      , name = "Algae 1"
      , settings = Settings.algae1
      }
    , { id = "algae2"
      , name = "Algae 2"
      , settings = Settings.algae2
      }
    , { id = "weed"
      , name = "Weed"
      , settings = Settings.weed
      }
    , { id = "triangle"
      , name = "Triangle"
      , settings = Settings.triangle
      }
    , { id = "quadraticGosper"
      , name = "Quadratic Gosper"
      , settings = Settings.quadraticGosper
      }
    , { id = "squareSierpinski"
      , name = "Square Sierpinski"
      , settings = Settings.squareSierpinski
      }
    , { id = "crystal"
      , name = "Crystal"
      , settings = Settings.crystal
      }
    , { id = "peanoCurve"
      , name = "Peano Curve"
      , settings = Settings.peanoCurve
      }
    , { id = "quadraticSnowflake1"
      , name = "Quadratic Snowflake 1"
      , settings = Settings.quadraticSnowflake1
      }
    , { id = "quadraticSnowflake2"
      , name = "Quadratic Snowflake 2"
      , settings = Settings.quadraticSnowflake2
      }
    , { id = "quadraticKochIsland1"
      , name = "Quadratic Koch Island 1"
      , settings = Settings.quadraticKochIsland1
      }
    , { id = "quadraticKochIsland2"
      , name = "Quadratic Koch Island 2"
      , settings = Settings.quadraticKochIsland2
      }
    , { id = "quadraticKochIsland3"
      , name = "Quadratic Koch Island 3"
      , settings = Settings.quadraticKochIsland3
      }
    , { id = "board"
      , name = "Board"
      , settings = Settings.board
      }
    , { id = "hilbert"
      , name = "Hilbert"
      , settings = Settings.hilbert
      }
    , { id = "sierpinskiArrowhead"
      , name = "Sierpinski Arrowhead"
      , settings = Settings.sierpinskiArrowhead
      }
    , { id = "vonKochSnowflake"
      , name = "von Koch Snowflake"
      , settings = Settings.vonKochSnowflake
      }
    , { id = "cross1"
      , name = "Cross 1"
      , settings = Settings.cross1
      }
    , { id = "cross2"
      , name = "Cross 2"
      , settings = Settings.cross2
      }
    , { id = "pentaplexity"
      , name = "Pentaplexity"
      , settings = Settings.pentaplexity
      }
    , { id = "rings"
      , name = "Rings"
      , settings = Settings.rings
      }
    , { id = "dragonCurve"
      , name = "Dragon Curve"
      , settings = Settings.dragonCurve
      }
    , { id = "hexagonalGosper"
      , name = "Hexagonal Gosper"
      , settings = Settings.hexagonalGosper
      }
    , { id = "levyCurve"
      , name = "Levy Curve"
      , settings = Settings.levyCurve
      }
    , { id = "classicSierpinskiCurve"
      , name = "Classic Sierpinski Curve"
      , settings = Settings.classicSierpinskiCurve
      }
    , { id = "krishnaAnklets"
      , name = "Krishna Anklets"
      , settings = Settings.krishnaAnklets
      }

    --
    -- TODO: Uncomment after openPolygon and closePolygon has been implemented.
    --
    --, { id = "mangoLeaf"
    --  , name = "Mango Leaf"
    --  , settings = Settings.mangoLeaf
    --  }
    --
    --, { id = "snakeKolam"
    --  , name = "Snake Kolam"
    --  , settings = Settings.snakeKolam
    --  }
    --
    , { id = "kolam"
      , name = "Kolam"
      , settings = Settings.kolam
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
