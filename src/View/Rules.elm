module View.Rules exposing (Msg, Rules, ViewOptions, init, update, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Html.Keyed as HK


type Rules
    = Rules State


type alias State =
    { ch : Char
    , replacement : String
    , id : Int
    , mapping : List ( Int, ( Char, String ) )
    }


init : Rules
init =
    Rules
        { ch = 'F'
        , replacement = ""
        , id = 0
        , mapping = []
        }


type Msg
    = SelectedCh String
    | InputReplacement String
    | ClickedAddRule
    | ClickedRemoveRule Int


update : Msg -> Rules -> Rules
update msg (Rules state) =
    case msg of
        SelectedCh chAsString ->
            case String.uncons chAsString of
                Just ( ch, "" ) ->
                    if String.any ((==) ch) chars then
                        Rules { state | ch = ch }

                    else
                        Rules state

                _ ->
                    Rules state

        InputReplacement replacement ->
            Rules { state | replacement = replacement }

        ClickedAddRule ->
            let
                isValidCh =
                    String.any ((==) state.ch) chars

                replacement =
                    String.trim state.replacement

                isValidReplacement =
                    replacement /= ""
            in
            if isValidCh && isValidReplacement then
                Rules
                    { state
                        | ch = 'F'
                        , replacement = ""
                        , id = state.id + 1
                        , mapping = state.mapping ++ [ ( state.id, ( state.ch, replacement ) ) ]
                    }

            else
                Rules state

        ClickedRemoveRule id ->
            let
                mapping =
                    List.filter (Tuple.first >> (/=) id) state.mapping
            in
            Rules { state | mapping = mapping }


type alias ViewOptions msg =
    { rules : Rules
    , onChange : Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { rules, onChange } =
    let
        { ch, replacement, mapping } =
            case rules of
                Rules state ->
                    state

        isDisabled =
            String.trim replacement == ""
    in
    H.map onChange <|
        H.div []
            [ H.p []
                [ H.label [ HA.for "replacement" ] [ H.text "Rules:" ]
                ]
            , H.p []
                [ viewSelect ch
                , H.input
                    [ HA.id "replacement"
                    , HA.type_ "text"
                    , HA.placeholder "F+F+F+F"
                    , HA.value replacement
                    , HE.onInput InputReplacement
                    ]
                    []
                , H.button
                    [ HA.type_ "button"
                    , if isDisabled then
                        HA.disabled True

                      else
                        HE.onClick ClickedAddRule
                    ]
                    [ H.text "Add rule" ]
                ]
            , viewMapping mapping
            ]


chars : String
chars =
    "Ff+-|[]#!@{}><&()abcdeghijklmnopqrstuvwxyz"


viewSelect : Char -> H.Html Msg
viewSelect selected =
    chars
        |> String.toList
        |> List.map
            (\ch ->
                viewOption { ch = ch, selected = selected }
            )
        |> H.select [ HE.onInput SelectedCh ]


viewOption : { ch : Char, selected : Char } -> H.Html msg
viewOption { ch, selected } =
    let
        value =
            String.fromChar ch
    in
    H.option
        [ HA.value value
        , HA.selected (ch == selected)
        ]
        [ H.text value ]


viewMapping : List ( Int, ( Char, String ) ) -> H.Html Msg
viewMapping mapping =
    HK.node "div" [ HA.class "rules" ] <|
        if mapping == [] then
            [ ( "no-rules", H.div [] [ H.text "No rules." ] )
            ]

        else
            List.map
                (\( id, ( ch, replacement ) ) ->
                    ( "rule-" ++ String.fromInt id
                    , H.div [ HA.class "rule" ]
                        [ H.text (String.fromChar ch ++ " -> " ++ replacement)
                        , H.text " "
                        , H.button
                            [ HA.class "remove-rule"
                            , HA.type_ "button"
                            , HE.onClick (ClickedRemoveRule id)
                            ]
                            [ H.text "Remove rule" ]
                        ]
                    )
                )
                mapping
