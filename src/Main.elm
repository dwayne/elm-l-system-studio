port module Main exposing (main)

import Browser as B
import Data.Angle as Angle exposing (Angle)
import Data.Dictionary as Dictionary
import Data.Field as F
import Data.Generator as Generator
import Data.Position exposing (Position)
import Data.Renderer as Renderer exposing (Renderer)
import Data.Settings as Settings exposing (Settings)
import Data.Transformer as Transformer exposing (Instruction)
import Data.Translator as Translator
import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Encode as JE
import Lib.Field as F
import Lib.Input as Input
import Lib.Maybe as Maybe
import View.Canvas as Canvas
import View.Field as Field
import View.FloatField as FloatField
import View.Fps as Fps exposing (Fps)
import View.Ipf as Ipf exposing (Ipf)
import View.LabeledInput as LabeledInput
import View.PanIncrement as PanIncrement exposing (PanIncrement)
import View.Preset as Preset
import View.Rules as Rules exposing (Rules)
import View.WindowPositionX as WindowPositionX exposing (WindowPositionX)
import View.WindowPositionY as WindowPositionY exposing (WindowPositionY)
import View.ZoomIncrement as ZoomIncrement exposing (ZoomIncrement)


main : Program () Model Msg
main =
    B.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Field a =
    F.Field () a


type alias Model =
    { rules : Rules
    , axiom : Field String
    , iterations : Field Int
    , startHeading : Field Angle
    , lineLength : Field Float
    , lineLengthScaleFactor : Field Float
    , turningAngle : Field Angle
    , windowPositionX : WindowPositionX
    , windowPositionY : WindowPositionY
    , windowSize : Field Float
    , fps : Fps
    , ipf : Ipf
    , settings : Settings
    , panIncrement : PanIncrement
    , zoomIncrement : ZoomIncrement
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
    , axiom = F.fromString F.nonEmptyString True settings.axiom
    , iterations = F.fromValue F.nonNegativeInt True settings.iterations
    , startHeading = F.fromValue F.angle True settings.startHeading
    , lineLength = F.fromValue F.nonNegativeFloat True settings.lineLength
    , lineLengthScaleFactor = F.fromValue F.nonNegativeFloat True settings.lineLengthScaleFactor
    , turningAngle = F.fromValue F.angle True settings.turningAngle
    , windowPositionX = WindowPositionX.init settings.windowPosition.x
    , windowPositionY = WindowPositionX.init settings.windowPosition.y
    , windowSize = F.fromValue F.nonNegativeFloat True settings.windowSize
    , fps = Fps.init settings.fps
    , ipf = Ipf.init settings.ipf
    , settings = settings
    , panIncrement = PanIncrement.init 10
    , zoomIncrement = ZoomIncrement.init 10
    , renderer = initRenderer settings
    }


render : Model -> ( Model, Cmd msg )
render model =
    let
        oldSettings =
            model.settings

        maybeNewSettings =
            (\axiom iterations startHeading lineLength lineLengthScaleFactor turningAngle windowPositionX windowPositionY windowSize fps ipf ->
                { oldSettings
                    | rules = Rules.toValue model.rules
                    , axiom = axiom
                    , iterations = iterations
                    , startHeading = startHeading
                    , lineLength = lineLength
                    , lineLengthScaleFactor = lineLengthScaleFactor
                    , turningAngle = turningAngle
                    , windowPosition = { x = windowPositionX, y = windowPositionY }
                    , windowSize = windowSize
                    , fps = fps
                    , ipf = ipf
                }
            )
                |> Just
                |> Maybe.apply (F.toMaybe model.axiom)
                |> Maybe.apply (F.toMaybe model.iterations)
                |> Maybe.apply (F.toMaybe model.startHeading)
                |> Maybe.apply (F.toMaybe model.lineLength)
                |> Maybe.apply (F.toMaybe model.lineLengthScaleFactor)
                |> Maybe.apply (F.toMaybe model.turningAngle)
                |> Maybe.apply (Field.toValue model.windowPositionX)
                |> Maybe.apply (Field.toValue model.windowPositionY)
                |> Maybe.apply (F.toMaybe model.windowSize)
                |> Maybe.apply (Field.toValue model.fps)
                |> Maybe.apply (Field.toValue model.ipf)
    in
    case maybeNewSettings of
        Just newSettings ->
            ( { model | settings = newSettings, renderer = initRenderer newSettings }
            , clear ()
            )

        Nothing ->
            ( model
            , Cmd.none
            )


isValid : Model -> Bool
isValid model =
    [ F.isInvalid model.axiom
    , F.isInvalid model.iterations
    , F.isInvalid model.startHeading
    , F.isInvalid model.lineLength
    , F.isInvalid model.lineLengthScaleFactor
    , F.isInvalid model.turningAngle
    , Field.toValue model.windowPositionX == Nothing
    , Field.toValue model.windowPositionY == Nothing
    , F.isInvalid model.windowSize
    , Field.toValue model.fps == Nothing
    , Field.toValue model.ipf == Nothing
    ]
        |> List.filter ((==) True)
        |> List.isEmpty


isValidPanIncrement : Model -> Bool
isValidPanIncrement { panIncrement } =
    Field.toValue panIncrement /= Nothing


isValidZoomIncrement : Bool -> Model -> Bool
isValidZoomIncrement isZoomingIn { windowSize, zoomIncrement } =
    (\size inc ->
        if isZoomingIn then
            size >= 2 * inc

        else
            True
    )
        |> Just
        |> Maybe.apply (F.toMaybe windowSize)
        |> Maybe.apply (Field.toValue zoomIncrement)
        |> Maybe.withDefault False


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
    = ChangedPreset Settings
    | ChangedRules Rules.Msg
    | InputAxiom String
    | InputIterations String
    | InputStartHeading String
    | InputLineLength String
    | InputLineLengthScaleFactor String
    | InputTurningAngle String
    | ChangedWindowPositionX Field.Msg
    | ChangedWindowPositionY Field.Msg
    | InputWindowSize String
    | ChangedFps Field.Msg
    | ChangedIpf Field.Msg
    | ChangedPanIncrement Field.Msg
    | ChangedZoomIncrement Field.Msg
    | ClickedRender
    | ClickedLeft
    | ClickedRight
    | ClickedUp
    | ClickedDown
    | ClickedIn
    | ClickedOut
    | ChangedRenderer Renderer.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedPreset settings ->
            ( setSettings
                { settings
                  --
                  -- N.B. Don't change FPS and IPF when the preset is changed.
                  --
                    | fps = model.settings.fps
                    , ipf = model.settings.ipf
                }
            , clear ()
            )

        ChangedRules subMsg ->
            ( { model | rules = Rules.update subMsg model.rules }
            , Cmd.none
            )

        InputAxiom s ->
            ( { model | axiom = F.fromString F.nonEmptyString False s }
            , Cmd.none
            )

        InputIterations s ->
            ( { model | iterations = F.fromString F.nonNegativeInt False s }
            , Cmd.none
            )

        InputStartHeading s ->
            ( { model | startHeading = F.fromString F.angle False s }
            , Cmd.none
            )

        InputLineLength s ->
            ( { model | lineLength = F.fromString F.nonNegativeFloat False s }
            , Cmd.none
            )

        InputLineLengthScaleFactor s ->
            ( { model | lineLengthScaleFactor = F.fromString F.nonNegativeFloat False s }
            , Cmd.none
            )

        InputTurningAngle s ->
            ( { model | turningAngle = F.fromString F.angle False s }
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

        InputWindowSize s ->
            ( { model | windowSize = F.fromString F.nonNegativeFloat False s }
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

        ChangedPanIncrement subMsg ->
            ( { model | panIncrement = PanIncrement.update subMsg }
            , Cmd.none
            )

        ChangedZoomIncrement subMsg ->
            ( { model | zoomIncrement = ZoomIncrement.update subMsg }
            , Cmd.none
            )

        ClickedRender ->
            render model

        ClickedLeft ->
            case Field.toValue model.panIncrement of
                Just panIncrement ->
                    render { model | windowPositionX = FloatField.changeBy -panIncrement model.windowPositionX }

                Nothing ->
                    ( model, Cmd.none )

        ClickedRight ->
            case Field.toValue model.panIncrement of
                Just panIncrement ->
                    render { model | windowPositionX = FloatField.changeBy panIncrement model.windowPositionX }

                Nothing ->
                    ( model, Cmd.none )

        ClickedUp ->
            case Field.toValue model.panIncrement of
                Just panIncrement ->
                    render { model | windowPositionY = FloatField.changeBy panIncrement model.windowPositionY }

                Nothing ->
                    ( model, Cmd.none )

        ClickedDown ->
            case Field.toValue model.panIncrement of
                Just panIncrement ->
                    render { model | windowPositionY = FloatField.changeBy -panIncrement model.windowPositionY }

                Nothing ->
                    ( model, Cmd.none )

        ClickedIn ->
            let
                maybeWindow =
                    (\x y size inc ->
                        let
                            inc2 =
                                2 * inc
                        in
                        if size >= inc2 then
                            Just
                                { x = x + inc
                                , y = y + inc
                                , size = size - inc2
                                }

                        else
                            Nothing
                    )
                        |> Just
                        |> Maybe.apply (Field.toValue model.windowPositionX)
                        |> Maybe.apply (Field.toValue model.windowPositionY)
                        |> Maybe.apply (F.toMaybe model.windowSize)
                        |> Maybe.apply (Field.toValue model.zoomIncrement)
                        |> Maybe.join
            in
            case maybeWindow of
                Just { x, y, size } ->
                    render
                        { model
                            | windowPositionX = FloatField.setValue x
                            , windowPositionY = FloatField.setValue y
                            , windowSize = F.fromValue F.nonNegativeFloat False size
                        }

                Nothing ->
                    ( model, Cmd.none )

        ClickedOut ->
            let
                maybeWindow =
                    (\x y size inc ->
                        let
                            inc2 =
                                2 * inc
                        in
                        { x = x - inc
                        , y = y - inc
                        , size = size + inc2
                        }
                    )
                        |> Just
                        |> Maybe.apply (Field.toValue model.windowPositionX)
                        |> Maybe.apply (Field.toValue model.windowPositionY)
                        |> Maybe.apply (F.toMaybe model.windowSize)
                        |> Maybe.apply (Field.toValue model.zoomIncrement)
            in
            case maybeWindow of
                Just { x, y, size } ->
                    render
                        { model
                            | windowPositionX = FloatField.setValue x
                            , windowPositionY = FloatField.setValue y
                            , windowSize = F.fromValue F.nonNegativeFloat False size
                        }

                Nothing ->
                    ( model, Cmd.none )

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
view ({ rules, axiom, iterations, startHeading, lineLength, lineLengthScaleFactor, turningAngle, windowPositionX, windowPositionY, windowSize, fps, ipf, settings, panIncrement, zoomIncrement, renderer } as model) =
    let
        canvasSize =
            settings.canvasSize

        { expectedFps, actualFps, cps, expectedIps, actualIps } =
            Renderer.toStats renderer
    in
    H.div []
        [ H.h1 [] [ H.text "L-System Studio" ]
        , viewLayout
            [ Preset.view
                { onSettings = ChangedPreset
                }
            , Rules.view
                { rules = rules
                , onChange = ChangedRules
                }
            , LabeledInput.view
                { id = "axiom"
                , label = "Axiom"
                , tipe = Input.String
                , isRequired = True
                , isDisabled = False
                , attrs = [ HA.placeholder "F+F+F+F" ]
                , field = axiom
                , onInput = InputAxiom
                }
            , LabeledInput.view
                { id = "iterations"
                , label = "Iterations"
                , tipe = Input.Int { min = Just 0, max = Nothing }
                , isRequired = True
                , isDisabled = False
                , attrs = [ HA.placeholder "3" ]
                , field = iterations
                , onInput = InputIterations
                }
            , LabeledInput.view
                { id = "start-heading"
                , label = "Start Heading"
                , tipe = Input.Float { min = Nothing, max = Nothing }
                , isRequired = True
                , isDisabled = False
                , attrs = [ HA.placeholder "0" ]
                , field = startHeading
                , onInput = InputStartHeading
                }
            , LabeledInput.view
                { id = "line-length"
                , label = "Line Length"
                , tipe = Input.Float { min = Just 0, max = Nothing }
                , isRequired = True
                , isDisabled = False
                , attrs = [ HA.placeholder "1" ]
                , field = lineLength
                , onInput = InputLineLength
                }
            , LabeledInput.view
                { id = "line-length-scale-factor"
                , label = "Line Length Scale Factor"
                , tipe = Input.Float { min = Just 0, max = Nothing }
                , isRequired = True
                , isDisabled = False
                , attrs = [ HA.placeholder "1" ]
                , field = lineLengthScaleFactor
                , onInput = InputLineLengthScaleFactor
                }
            , LabeledInput.view
                { id = "turning-angle"
                , label = "Turning Angle"
                , tipe = Input.Float { min = Nothing, max = Nothing }
                , isRequired = True
                , isDisabled = False
                , attrs = [ HA.placeholder "90" ]
                , field = turningAngle
                , onInput = InputTurningAngle
                }
            , WindowPositionX.view
                { windowPositionX = windowPositionX
                , onChange = ChangedWindowPositionX
                }
            , WindowPositionY.view
                { windowPositionY = windowPositionY
                , onChange = ChangedWindowPositionY
                }
            , LabeledInput.view
                { id = "window-size"
                , label = "Window Size"
                , tipe = Input.Float { min = Just 0, max = Nothing }
                , isRequired = True
                , isDisabled = False
                , attrs = [ HA.placeholder "100" ]
                , field = windowSize
                , onInput = InputWindowSize
                }
            , Fps.view
                { fps = fps
                , onChange = ChangedFps
                }
            , Ipf.view
                { ipf = ipf
                , onChange = ChangedIpf
                }
            , H.p []
                [ H.button
                    [ HA.type_ "button"
                    , if isValid model then
                        HE.onClick ClickedRender

                      else
                        HA.disabled True
                    ]
                    [ H.text "Render" ]
                ]
            ]
            [ Canvas.view
                { id = "canvas"
                , width = canvasSize
                , height = canvasSize
                }
            , H.p []
                [ PanIncrement.view
                    { panIncrement = panIncrement
                    , onChange = ChangedPanIncrement
                    }
                , H.text "Pan: "
                , H.button
                    [ HA.type_ "button"
                    , if isValidPanIncrement model then
                        HE.onClick ClickedLeft

                      else
                        HA.disabled True
                    ]
                    [ H.text "Left" ]
                , H.text " "
                , H.button
                    [ HA.type_ "button"
                    , if isValidPanIncrement model then
                        HE.onClick ClickedRight

                      else
                        HA.disabled True
                    ]
                    [ H.text "Right" ]
                , H.text " "
                , H.button
                    [ HA.type_ "button"
                    , if isValidPanIncrement model then
                        HE.onClick ClickedUp

                      else
                        HA.disabled True
                    ]
                    [ H.text "Up" ]
                , H.text " "
                , H.button
                    [ HA.type_ "button"
                    , if isValidPanIncrement model then
                        HE.onClick ClickedDown

                      else
                        HA.disabled True
                    ]
                    [ H.text "Down" ]
                ]
            , H.p []
                [ ZoomIncrement.view
                    { zoomIncrement = zoomIncrement
                    , onChange = ChangedZoomIncrement
                    }
                , H.text "Zoom: "
                , H.button
                    [ HA.type_ "button"
                    , if isValidZoomIncrement True model then
                        HE.onClick ClickedIn

                      else
                        HA.disabled True
                    ]
                    [ H.text "In" ]
                , H.text " "
                , H.button
                    [ HA.type_ "button"
                    , if isValidZoomIncrement False model then
                        HE.onClick ClickedOut

                      else
                        HA.disabled True
                    ]
                    [ H.text "Out" ]
                ]
            , H.div [ HA.class "stats" ]
                [ H.p [] [ H.text <| "Expected FPS = " ++ String.fromFloat expectedFps ]
                , H.p [] [ H.text <| "Actual FPS = " ++ String.fromFloat actualFps ]
                , H.p [] [ H.text <| "CPS = " ++ String.fromFloat cps ]
                , H.p [] [ H.text <| "Expected IPS = " ++ String.fromFloat expectedIps ]
                , H.p [] [ H.text <| "Actual IPS = " ++ String.fromFloat actualIps ]
                ]
            ]
        ]


viewLayout : List (H.Html msg) -> List (H.Html msg) -> H.Html msg
viewLayout region1 region2 =
    H.div [ HA.class "layout" ]
        [ H.div [ HA.class "region1" ] region1
        , H.div [ HA.class "region2" ] region2
        ]
