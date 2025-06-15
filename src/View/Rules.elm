module View.Rules exposing (Msg, Rules, ViewOptions, init, toValue, update, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Html.Keyed as HK
import Lib.Field as F
import Lib.Input as Input


type Rules
    = Rules State


type alias Field a =
    F.Field () a


type alias State =
    { ch : Char
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
        { ch = 'F'
        , replacement = F.fromString F.nonEmptyString True ""
        , id = id
        , mapping = mapping
        }


toValue : Rules -> List ( Char, String )
toValue (Rules { mapping }) =
    List.map Tuple.second mapping


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
                    if isValidChar ch then
                        Rules { state | ch = ch }

                    else
                        Rules state

                _ ->
                    Rules state

        InputReplacement s ->
            Rules { state | replacement = F.fromString F.nonEmptyString False s }

        ClickedAddRule ->
            case toRule state.ch state.replacement of
                Just rule ->
                    Rules
                        { state
                            | ch = 'F'
                            , replacement = F.fromString F.nonEmptyString True ""
                            , id = state.id + 1
                            , mapping = state.mapping ++ [ ( state.id, rule ) ]
                        }

                Nothing ->
                    Rules state

        ClickedRemoveRule id ->
            let
                mapping =
                    List.filter (Tuple.first >> (/=) id) state.mapping
            in
            Rules { state | mapping = mapping }


toRule : Char -> Field String -> Maybe ( Char, String )
toRule ch =
    F.toMaybe
        >> Maybe.andThen
            (\replacement ->
                if isValidChar ch then
                    Just ( ch, replacement )

                else
                    Nothing
            )


isValidChar : Char -> Bool
isValidChar ch =
    String.any ((==) ch) chars


chars : String
chars =
    "Ff+-|[]#!@{}><&()ABCDEGHIJKLMNOPQRSTUVWXYZabcdeghijklmnopqrstuvwxyz"


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
            not (isValidChar ch && F.isValid replacement)
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
