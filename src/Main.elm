port module Main exposing (main)

import Browser as B
import Data.Angle as Angle
import Data.Dictionary as Dictionary
import Data.Generator as Generator
import Data.Position exposing (Position)
import Data.Renderer as Renderer exposing (Renderer)
import Data.Settings as Settings exposing (Settings)
import Data.Transformer as Transformer exposing (Instruction)
import Data.Translator as Translator
import Html as H
import Json.Encode as JE
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
    { settings : Settings
    , renderer : Renderer Instruction
    }


init : () -> ( Model, Cmd msg )
init =
    let
        rules =
            [ ( 'F', "F+F-F-FF+F+F-F" ) ]

        axiom =
            "F+F+F+F"

        defaultSettings =
            Settings.default rules axiom

        settings =
            { defaultSettings
                | turningAngle = Angle.fromDegrees 90
                , windowPosition = { x = -25, y = -25 }
                , windowSize = 100
                , canvasSize = canvasSize
            }
    in
    always
        ( { settings = settings
          , renderer = initRenderer settings
          }
        , Cmd.none
        )


initRenderer : Settings -> Renderer Instruction
initRenderer settings =
    let
        rules =
            settings.rules

        axiom =
            settings.axiom

        iterations =
            settings.iterations

        dictionary =
            settings.dictionary

        translateOptions =
            Settings.toTranslateOptions settings

        transformOptions =
            Settings.toTransformOptions settings

        chars =
            Generator.generate settings.iterations settings.rules settings.axiom

        instructions =
            chars
                |> Translator.translate dictionary translateOptions
                |> Transformer.transform transformOptions
    in
    Renderer.init
        { fps = settings.fps
        , ipf = settings.ipf
        , instructions = instructions
        }



-- UPDATE


type Msg
    = ChangedRenderer Renderer.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedRenderer subMsg ->
            let
                ( renderer, commands ) =
                    Renderer.update Transformer.encode subMsg model.renderer
            in
            ( { model | renderer = renderer }
            , draw commands
            )


port draw : JE.Value -> Cmd msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Renderer.subscriptions ChangedRenderer model.renderer



-- VIEW


view : Model -> H.Html msg
view { renderer } =
    let
        { expectedFps, actualFps, cps, expectedIps, actualIps } =
            Renderer.toStats renderer
    in
    H.div []
        [ Canvas.view
            { id = "canvas"
            , width = canvasSize
            , height = canvasSize
            }
        , H.p [] [ H.text <| "Expected FPS = " ++ String.fromFloat expectedFps ]
        , H.p [] [ H.text <| "Actual FPS = " ++ String.fromFloat actualFps ]
        , H.p [] [ H.text <| "CPS = " ++ String.fromFloat cps ]
        , H.p [] [ H.text <| "Expected IPS = " ++ String.fromFloat expectedIps ]
        , H.p [] [ H.text <| "Actual IPS = " ++ String.fromFloat actualIps ]
        ]
