module Main exposing (main)

import Browser as B
import Data.Angle as Angle
import Data.Dictionary as Dictionary
import Data.Generator as Generator
import Data.Renderer as Renderer exposing (Renderer)
import Data.Settings as Settings
import Data.Translator as Translator
import Html as H
import Html.Attributes as HA
import View.Canvas as Canvas
import Lib.Sequence as Sequence


main : Program () Model Msg
main =
    B.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { renderer : Renderer
    }


init : () -> ( Model, Cmd msg )
init =
    let
        rules =
            [ ( 'F', "F-F++F-F" )
            ]

        axiom =
            "F++F++F"
            --"FF"

        chars =
            Generator.generate 6 rules axiom
            --Generator.generate 0 rules axiom

        defaultSettings =
            Settings.default

        settings =
            { defaultSettings
                | startPosition = { x = 300, y = 300 }
                --, lineLength = 50
                , lineLength = 6
                , turningAngle = Angle.fromDegrees 60
            }

        instructions =
            Translator.translate Dictionary.default settings chars
    in
    always
        ( { renderer =
                Renderer.init
                    { fps = 60
                    , ipf = 100
                    , instructions = instructions
                    }
          }
        , Cmd.none
        )
        |> Debug.log (Debug.toString <| "length = " ++ String.fromInt (Sequence.length instructions))



-- UPDATE


type Msg
    = ChangedRenderer Renderer.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedRenderer subMsg ->
            ( { model | renderer = Renderer.update ChangedRenderer subMsg model.renderer }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Renderer.subscriptions ChangedRenderer model.renderer



-- VIEW


view : Model -> H.Html msg
view { renderer } =
    let
        { expectedFps, actualFps, cps, commands } =
            Renderer.toInfo renderer
    in
    H.div []
        [ Canvas.view
            { width = 800
            , height = 600
            , commands = commands
            , attrs = [ HA.style "border" "1px solid black" ]
            }
        , H.p [] [ H.text <| "Expected FPS = " ++ String.fromFloat expectedFps ]
        , H.p [] [ H.text <| "Actual FPS = " ++ String.fromFloat actualFps ]
        , H.p [] [ H.text <| "CPS = " ++ String.fromFloat cps ]
        ]
