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
import View.Axiom as Axiom exposing (Axiom)
import View.Canvas as Canvas
import View.Field as Field
import View.Iterations as Iterations exposing (Iterations)


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
    { axiom : Axiom
    , iterations : Iterations
    , settings : Settings
    , renderer : Renderer Instruction
    }


init : () -> ( Model, Cmd msg )
init =
    let
        settings =
            Settings.kochCurve
    in
    always
        ( { axiom = Axiom.init settings.axiom
          , iterations = Iterations.init settings.iterations
          , settings = settings
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
    = ChangedAxiom Field.Msg
    | ChangedIterations Field.Msg
    | ChangedRenderer Renderer.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedAxiom subMsg ->
            ( { model | axiom = Axiom.update subMsg }
            , Cmd.none
            )

        ChangedIterations subMsg ->
            ( { model | iterations = Iterations.update subMsg }
            , Cmd.none
            )

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


view : Model -> H.Html Msg
view { axiom, iterations, settings, renderer } =
    let
        canvasSize =
            settings.canvasSize

        { expectedFps, actualFps, cps, expectedIps, actualIps } =
            Renderer.toStats renderer
    in
    H.div []
        [ Axiom.view
            { axiom = axiom
            , onChange = ChangedAxiom
            }
        , Iterations.view
            { iterations = iterations
            , onChange = ChangedIterations
            }
        , Canvas.view
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
