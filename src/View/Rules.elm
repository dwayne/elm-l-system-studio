module View.Rules exposing (Msg, Rules, ViewOptions, init, toValue, update, view)

import Field as F exposing (Field)
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Html.Keyed as HK
import Lib.Input as Input


type Rules
    = Rules State


type alias State =
    { ch : Field Char
    , replacement : Field String
    , id : Int
    , mapping : List ( Int, ( Char, String ) )
    }


init : List ( Char, String ) -> Rules
init rawMapping =
    let
        mapping =
            rawMapping
                |> List.filterMap
                    (\( ch, replacement ) ->
                        let
                            trimmedReplacement =
                                String.trim replacement
                        in
                        if isValidChar ch && trimmedReplacement /= "" then
                            Just ( ch, trimmedReplacement )

                        else
                            Nothing
                    )
                |> List.indexedMap Tuple.pair

        id =
            List.length mapping
    in
    Rules
        { ch = F.fromValue (F.subsetOfChar isValidChar) 'F'
        , replacement = F.empty F.nonBlankString
        , id = id
        , mapping = mapping
        }


isValidChar : Char -> Bool
isValidChar ch =
    String.any ((==) ch) chars


chars : String
chars =
    "Ff+-|[]#!@{}><&()ABCDEGHIJKLMNOPQRSTUVWXYZabcdeghijklmnopqrstuvwxyz"


toValue : Rules -> List ( Char, String )
toValue (Rules { mapping }) =
    List.map Tuple.second mapping



-- UPDATE


type Msg
    = InputCh String
    | InputReplacement String
    | ClickedAddRule
    | ClickedRemoveRule Int


update : Msg -> Rules -> Rules
update msg ((Rules state) as rules) =
    case msg of
        InputCh s ->
            Rules { state | ch = F.setFromString s state.ch }

        InputReplacement s ->
            Rules { state | replacement = F.setFromString s state.replacement }

        ClickedAddRule ->
            (\ch replacement ->
                Rules
                    { state
                        | ch = F.fromValue (F.subsetOfChar isValidChar) 'F'
                        , replacement = F.empty F.nonBlankString
                        , id = state.id + 1
                        , mapping = state.mapping ++ [ ( state.id, ( ch, replacement ) ) ]
                    }
            )
                |> Just
                |> F.applyMaybe state.ch
                |> F.applyMaybe state.replacement
                |> Maybe.withDefault rules

        ClickedRemoveRule id ->
            Rules { state | mapping = List.filter (Tuple.first >> (/=) id) state.mapping }



-- VIEW


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
            F.isInvalid ch || F.isInvalid replacement
    in
    H.map onChange <|
        H.div []
            [ H.p []
                [ H.label [ HA.for "replacement" ] [ H.text "Rules:" ]
                ]
            , H.p []
                [ viewSelect ch
                , H.text " "
                , Input.view
                    { tipe = Input.string
                    , isRequired = True
                    , isDisabled = False
                    , attrs =
                        [ HA.id "replacement"
                        , HA.placeholder "F+F+F+F"
                        ]
                    , field = replacement
                    , onInput = InputReplacement
                    }
                , H.text " "
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


viewSelect : Field Char -> H.Html Msg
viewSelect selectedAsField =
    let
        selected =
            selectedAsField
                |> F.toMaybe
                |> Maybe.withDefault 'F'
    in
    chars
        |> String.toList
        |> List.map
            (\ch ->
                viewOption { ch = ch, selected = selected }
            )
        |> H.select [ HE.onInput InputCh ]


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
