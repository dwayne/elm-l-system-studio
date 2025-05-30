module Main exposing (main)

import Browser as B
import Data.Angle as Angle
import Data.Dictionary as Dictionary
import Data.Generator as Generator
import Data.Position exposing (Position)
import Data.Renderer as Renderer exposing (Renderer)
import Data.Settings as Settings
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


windowPosition : Position
windowPosition =
    { x = -125
    , y = -300
    }


windowSize : Float
windowSize =
    1000


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
            [ ( 'F', "F-F++F-F" )
            ]

        axiom =
            "F++F++F"

        chars =
            Generator.generate 6 rules axiom

        defaultSettings =
            Settings.default

        settings =
            { defaultSettings
                | startPosition = { x = 0, y = 0 }
                , lineLength = 1
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



-- UPDATE


type Msg
    = ChangedRenderer Renderer.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedRenderer subMsg ->
            let
                ( renderer, cmd ) =
                    Renderer.update
                        { renderingOptions =
                            { windowPosition = windowPosition
                            , windowSize = windowSize
                            , canvasSize = toFloat canvasSize
                            }
                        }
                        subMsg
                        model.renderer
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
