module View.Input.Iterations exposing (Iterations, Msg, ViewOptions, init, update, view)

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD


type Iterations
    = Iterations State


type alias State =
    { raw : String
    , processed : Processed Int
    }


type Processed a
    = Default a
    | Valid a
    | Invalid


init : Int -> Iterations
init n =
    Iterations
        { raw = String.fromInt n
        , processed =
            if n >= 0 then
                Default n

            else
                Invalid
        }


type Msg
    = Input String


update : Msg -> Iterations
update msg =
    case msg of
        Input raw ->
            Iterations
                { raw = raw
                , processed =
                    case String.toInt raw of
                        Just n ->
                            if n >= 0 then
                                Valid n

                            else
                                Invalid

                        Nothing ->
                            Invalid
                }


type alias ViewOptions msg =
    { iterations : Iterations
    , onChange : Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { iterations, onChange } =
    let
        { raw, processed } =
            case iterations of
                Iterations state ->
                    state
    in
    H.p []
        [ H.label [ HA.for "iterations" ] [ H.text "Iterations" ]
        , H.span [] [ H.text ": " ]
        , H.input
            [ HA.id "iterations"
            , HA.type_ "number"
            , HA.required True
            , HA.min "0"
            , HA.placeholder "3"
            , HA.value raw
            , HA.attribute "data-state" <|
                case processed of
                    Default _ ->
                        "default"

                    Valid _ ->
                        "valid"

                    Invalid ->
                        "invalid"
            , HE.onInput (onChange << Input)
            ]
            []
        ]
