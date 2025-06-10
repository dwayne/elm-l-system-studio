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
import Html.Attributes as HA
import Json.Encode as JE
import View.Axiom as Axiom exposing (Axiom)
import View.Canvas as Canvas
import View.Field as Field
import View.Fps as Fps exposing (Fps)
import View.Ipf as Ipf exposing (Ipf)
import View.Iterations as Iterations exposing (Iterations)
import View.LineLength as LineLength exposing (LineLength)
import View.LineLengthScaleFactor as LineLengthScaleFactor exposing (LineLengthScaleFactor)
import View.Preset as Preset
import View.Rules as Rules exposing (Rules)
import View.StartHeading as StartHeading exposing (StartHeading)
import View.TurningAngle as TurningAngle exposing (TurningAngle)
import View.WindowPositionX as WindowPositionX exposing (WindowPositionX)
import View.WindowPositionY as WindowPositionY exposing (WindowPositionY)
import View.WindowSize as WindowSize exposing (WindowSize)


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
    { rules : Rules
    , axiom : Axiom
    , iterations : Iterations
    , startHeading : StartHeading
    , lineLength : LineLength
    , lineLengthScaleFactor : LineLengthScaleFactor
    , turningAngle : TurningAngle
    , windowPositionX : WindowPositionX
    , windowPositionY : WindowPositionY
    , windowSize : WindowSize
    , fps : Fps
    , ipf : Ipf
    , settings : Settings
    , renderer : Renderer Instruction
    }


init : () -> ( Model, Cmd msg )
init =
    always
        ( setSettings Settings.kochCurve
        , clear ()
        )


setSettings : Settings -> Model
setSettings settings =
    { rules = Rules.init settings.rules
    , axiom = Axiom.init settings.axiom
    , iterations = Iterations.init settings.iterations
    , startHeading = StartHeading.init settings.startHeading
    , lineLength = LineLength.init settings.lineLength
    , lineLengthScaleFactor = LineLengthScaleFactor.init settings.lineLengthScaleFactor
    , turningAngle = TurningAngle.init settings.turningAngle
    , windowPositionX = WindowPositionX.init settings.windowPosition.x
    , windowPositionY = WindowPositionX.init settings.windowPosition.y
    , windowSize = WindowSize.init settings.windowSize
    , fps = Fps.init settings.fps
    , ipf = Ipf.init settings.ipf
    , settings = settings
    , renderer = initRenderer settings
    }


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
    = ChangedSettings Settings
    | ChangedRules Rules.Msg
    | ChangedAxiom Field.Msg
    | ChangedIterations Field.Msg
    | ChangedStartHeading Field.Msg
    | ChangedLineLength Field.Msg
    | ChangedLineLengthScaleFactor Field.Msg
    | ChangedTurningAngle Field.Msg
    | ChangedWindowPositionX Field.Msg
    | ChangedWindowPositionY Field.Msg
    | ChangedWindowSize Field.Msg
    | ChangedFps Field.Msg
    | ChangedIpf Field.Msg
    | ChangedRenderer Renderer.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedSettings settings ->
            ( setSettings settings
            , clear ()
            )

        ChangedRules subMsg ->
            ( { model | rules = Rules.update subMsg model.rules }
            , Cmd.none
            )

        ChangedAxiom subMsg ->
            ( { model | axiom = Axiom.update subMsg }
            , Cmd.none
            )

        ChangedIterations subMsg ->
            ( { model | iterations = Iterations.update subMsg }
            , Cmd.none
            )

        ChangedStartHeading subMsg ->
            ( { model | startHeading = StartHeading.update subMsg }
            , Cmd.none
            )

        ChangedLineLength subMsg ->
            ( { model | lineLength = LineLength.update subMsg }
            , Cmd.none
            )

        ChangedLineLengthScaleFactor subMsg ->
            ( { model | lineLengthScaleFactor = LineLengthScaleFactor.update subMsg }
            , Cmd.none
            )

        ChangedTurningAngle subMsg ->
            ( { model | turningAngle = TurningAngle.update subMsg }
            , Cmd.none
            )

        ChangedWindowPositionX subMsg ->
            ( { model | windowPositionX = WindowPositionX.update subMsg }
            , Cmd.none
            )

        ChangedWindowPositionY subMsg ->
            ( { model | windowPositionY = WindowPositionY.update subMsg }
            , Cmd.none
            )

        ChangedWindowSize subMsg ->
            ( { model | windowSize = WindowSize.update subMsg }
            , Cmd.none
            )

        ChangedFps subMsg ->
            ( { model | fps = Fps.update subMsg }
            , Cmd.none
            )

        ChangedIpf subMsg ->
            ( { model | ipf = Ipf.update subMsg }
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


port clear : () -> Cmd msg


port draw : JE.Value -> Cmd msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Renderer.subscriptions ChangedRenderer model.renderer



-- VIEW


view : Model -> H.Html Msg
view { rules, axiom, iterations, startHeading, lineLength, lineLengthScaleFactor, turningAngle, windowPositionX, windowPositionY, windowSize, fps, ipf, settings, renderer } =
    let
        canvasSize =
            settings.canvasSize

        { expectedFps, actualFps, cps, expectedIps, actualIps } =
            Renderer.toStats renderer
    in
    viewLayout
        [ Preset.view
            { onSettings = ChangedSettings
            }
        , Rules.view
            { rules = rules
            , onChange = ChangedRules
            }
        , Axiom.view
            { axiom = axiom
            , onChange = ChangedAxiom
            }
        , Iterations.view
            { iterations = iterations
            , onChange = ChangedIterations
            }
        , StartHeading.view
            { startHeading = startHeading
            , onChange = ChangedStartHeading
            }
        , LineLength.view
            { lineLength = lineLength
            , onChange = ChangedLineLength
            }
        , LineLengthScaleFactor.view
            { lineLengthScaleFactor = lineLengthScaleFactor
            , onChange = ChangedLineLengthScaleFactor
            }
        , TurningAngle.view
            { turningAngle = turningAngle
            , onChange = ChangedTurningAngle
            }
        , WindowPositionX.view
            { windowPositionX = windowPositionX
            , onChange = ChangedWindowPositionX
            }
        , WindowPositionY.view
            { windowPositionY = windowPositionY
            , onChange = ChangedWindowPositionY
            }
        , WindowSize.view
            { windowSize = windowSize
            , onChange = ChangedWindowSize
            }
        , Fps.view
            { fps = fps
            , onChange = ChangedFps
            }
        , Ipf.view
            { ipf = ipf
            , onChange = ChangedIpf
            }
        ]
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


viewLayout : List (H.Html msg) -> List (H.Html msg) -> H.Html msg
viewLayout region1 region2 =
    H.div [ HA.class "layout" ]
        [ H.div [ HA.class "region1" ] region1
        , H.div [ HA.class "region2" ] region2
        ]
