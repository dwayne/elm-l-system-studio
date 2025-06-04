module Main exposing (main)

import Browser as B
import Data.Angle as Angle
import Data.Dictionary as Dictionary
import Data.DivRenderer as Renderer exposing (Renderer)
import Data.Generator as Generator
import Data.Position exposing (Position)
import Data.Settings as Settings
import Data.SvgTransformer as Transformer
import Data.SvgTranslator as Translator
import Html as H
import View.Canvas as Canvas


main : Program () (Model Msg) Msg
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


type alias Model msg =
    { renderer : Renderer msg
    }


init : () -> ( Model msg, Cmd msg )
init =
    let
        rules =
            [ ( 'F', "F+F-F-FF+F+F-F" ) ]

        axiom =
            "F+F+F+F"

        chars =
            Generator.generate 6 rules axiom

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
                --Renderer.init
                --    { fps = 30
                --    , ipf = 10
                --    , instructions = instructions
                --    }
                --Renderer.init instructions
                Renderer.init
          }
        , Cmd.none
        )



-- UPDATE


type Msg
    = ChangedRenderer Renderer.Msg


update : Msg -> Model msg -> ( Model msg, Cmd msg )
update msg model =
    case msg of
        ChangedRenderer subMsg ->
            let
                renderer =
                    Renderer.update subMsg model.renderer
            in
            ( { model | renderer = renderer }
            , Cmd.none
            )


subscriptions : Model Msg -> Sub Msg
subscriptions model =
    Renderer.subscriptions ChangedRenderer model.renderer



-- VIEW


view : Model msg -> H.Html msg
view { renderer } =
    --let
    --    { expectedFps, actualFps, cps, ips } =
    --        Renderer.toInfo renderer
    --in
    H.div []
        --[ Renderer.view
        --    { width = canvasSize
        --    , height = canvasSize
        --    , renderer = renderer
        --    }
        [ Renderer.view { renderer = renderer }

        --, H.p [] [ H.text <| "Expected FPS = " ++ String.fromFloat expectedFps ]
        --, H.p [] [ H.text <| "Actual FPS = " ++ String.fromFloat actualFps ]
        --, H.p [] [ H.text <| "Calls per second (CPS) = " ++ String.fromFloat cps ]
        --, H.p [] [ H.text <| "Instructions per seconds (IPS) = " ++ String.fromFloat ips ]
        ]
