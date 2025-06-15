module View.Preset exposing (ViewOptions, view)

import Data.Field as F
import Data.Preset as Preset exposing (Preset)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD
import Lib.Field as F


type alias ViewOptions e msg =
    { preset : F.Field e Preset
    , onPreset : Preset -> msg
    }


view : ViewOptions e msg -> H.Html msg
view { preset, onPreset } =
    let
        maybePresetId =
            preset
                |> F.toMaybe
                |> Maybe.map .id
    in
    H.p []
        [ H.label [ HA.for "preset" ] [ H.text "Preset" ]
        , H.text ": "
        , H.select
            [ HA.id "preset"
            , onInput onPreset
            ]
            (List.map
                (\{ id, name } ->
                    H.option
                        [ HA.value id
                        , HA.selected (Just id == maybePresetId)
                        ]
                        [ H.text name ]
                )
                Preset.presets
            )
        ]



-- EVENTS


onInput : (Preset -> msg) -> H.Attribute msg
onInput toMsg =
    let
        decoder =
            HE.targetValue
                |> JD.andThen
                    (\s ->
                        case Preset.fromId s of
                            Just preset ->
                                JD.succeed ( toMsg preset, True )

                            Nothing ->
                                JD.fail ("Unknown preset: " ++ s)
                    )
    in
    HE.stopPropagationOn "input" decoder
