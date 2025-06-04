module Main exposing (main)

import Browser as B
import Data.Angle as Angle
import Data.Dictionary as Dictionary
import Data.Generator as Generator
import Data.Position exposing (Position)
import Data.Renderer as Renderer exposing (Renderer)
import Data.Settings as Settings
import Data.Transformer as Transformer
import Data.Translator as Translator
import Html as H
import View.Canvas as Canvas


main : Program () Model Msg
main =
    B.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- CONSTANTS


canvasSize : Int
canvasSize =
    500



-- MODEL


type alias Model =
    { renderer : Renderer
    }


init : () -> ( Model, Cmd msg )
init =
    let
        rules =
            [ ( 'F', "F+F-F-FF+F+F-F" ) ]

        axiom =
            "F+F+F+F"

        chars =
            Generator.generate 3 rules axiom

        defaultSettings =
            Settings.default

        settings =
            { defaultSettings
                | lineLength = 1
                , turningAngle = Angle.fromDegrees 90
            }

        transformOptions =
            { windowPosition = { x = -25, y = -25 }
            , windowSize = 100
            , canvasSize = canvasSize
            }

        instructions =
            chars
                |> Translator.translate Dictionary.default settings
                |> Transformer.transform transformOptions
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



-- UPDATE


type Msg
    = ChangedRenderer Renderer.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedRenderer subMsg ->
            let
                ( renderer, cmd ) =
                    Renderer.update subMsg model.renderer
            in
            ( { model | renderer = renderer }
            , cmd
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Renderer.subscriptions ChangedRenderer model.renderer



-- VIEW


view : Model -> H.Html msg
view { renderer } =
    let
        { expectedFps, actualFps, cps, ips, commands } =
            Renderer.toInfo renderer
    in
    H.div []
        [ Canvas.view
            { id = "canvas"
            , width = canvasSize
            , height = canvasSize
            }
        , H.p [] [ H.text <| "Expected FPS = " ++ String.fromFloat expectedFps ]
        , H.p [] [ H.text <| "Actual FPS = " ++ String.fromFloat actualFps ]
        , H.p [] [ H.text <| "Calls per second (CPS) = " ++ String.fromFloat cps ]
        , H.p [] [ H.text <| "Instructions per seconds (IPS) = " ++ String.fromFloat ips ]
        ]
