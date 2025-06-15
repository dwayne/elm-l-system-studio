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
import View.LabeledInput as LabeledInput
import View.Preset as Preset
import View.Rules as Rules exposing (Rules)


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
    , windowPositionX : Field Float
    , windowPositionY : Field Float
    , windowSize : Field Float
    , fps : Field Int
    , ipf : Field Int
    , panIncrement : Field Float
    , zoomIncrement : Field Float
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
    , axiom = F.fromString F.nonEmptyString True settings.axiom
    , iterations = F.fromValue F.nonNegativeInt True settings.iterations
    , startHeading = F.fromValue F.angle True settings.startHeading
    , lineLength = F.fromValue F.nonNegativeFloat True settings.lineLength
    , lineLengthScaleFactor = F.fromValue F.nonNegativeFloat True settings.lineLengthScaleFactor
    , turningAngle = F.fromValue F.angle True settings.turningAngle
    , windowPositionX = F.fromValue F.float True settings.windowPosition.x
    , windowPositionY = F.fromValue F.float True settings.windowPosition.y
    , windowSize = F.fromValue F.nonNegativeFloat True settings.windowSize
    , fps = F.fromValue F.fps True settings.fps
    , ipf = F.fromValue F.ipf True settings.ipf
    , panIncrement = F.fromValue F.panIncrement True 10
    , zoomIncrement = F.fromValue F.zoomIncrement True 10
    , settings = settings
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
                |> Maybe.apply (F.toMaybe model.windowPositionX)
                |> Maybe.apply (F.toMaybe model.windowPositionY)
                |> Maybe.apply (F.toMaybe model.windowSize)
                |> Maybe.apply (F.toMaybe model.fps)
                |> Maybe.apply (F.toMaybe model.ipf)
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
    , F.isInvalid model.windowPositionX
    , F.isInvalid model.windowPositionY
    , F.isInvalid model.windowSize
    , F.isInvalid model.fps
    , F.isInvalid model.ipf
    ]
        |> List.filter ((==) True)
        |> List.isEmpty


isValidZoomIncrement :
    { isZoomingIn : Bool
    , windowSize : Field Float
    , zoomIncrement : Field Float
    }
    -> Bool
isValidZoomIncrement { isZoomingIn, windowSize, zoomIncrement } =
    (\size inc ->
        if isZoomingIn then
            size >= 2 * inc

        else
            True
    )
        |> Just
        |> Maybe.apply (F.toMaybe windowSize)
        |> Maybe.apply (F.toMaybe zoomIncrement)
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
    | InputWindowPositionX String
    | InputWindowPositionY String
    | InputWindowSize String
    | InputFps String
    | InputIpf String
    | InputPanIncrement String
    | InputZoomIncrement String
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

        InputWindowPositionX s ->
            ( { model | windowPositionX = F.fromString F.float False s }
            , Cmd.none
            )

        InputWindowPositionY s ->
            ( { model | windowPositionY = F.fromString F.float False s }
            , Cmd.none
            )

        InputWindowSize s ->
            ( { model | windowSize = F.fromString F.nonNegativeFloat False s }
            , Cmd.none
            )

        InputFps s ->
            ( { model | fps = F.fromString F.fps False s }
            , Cmd.none
            )

        InputIpf s ->
            ( { model | ipf = F.fromString F.ipf False s }
            , Cmd.none
            )

        InputPanIncrement s ->
            ( { model | panIncrement = F.fromString F.panIncrement False s }
            , Cmd.none
            )

        InputZoomIncrement s ->
            ( { model | zoomIncrement = F.fromString F.zoomIncrement False s }
            , Cmd.none
            )

        ClickedRender ->
            render model

        ClickedLeft ->
            case ( F.toMaybe model.windowPositionX, F.toMaybe model.panIncrement ) of
                ( Just windowPositionX, Just panIncrement ) ->
                    render { model | windowPositionX = F.fromValue F.float False (windowPositionX - panIncrement) }

                _ ->
                    ( model, Cmd.none )

        ClickedRight ->
            case ( F.toMaybe model.windowPositionX, F.toMaybe model.panIncrement ) of
                ( Just windowPositionX, Just panIncrement ) ->
                    render { model | windowPositionX = F.fromValue F.float False (windowPositionX + panIncrement) }

                _ ->
                    ( model, Cmd.none )

        ClickedUp ->
            case ( F.toMaybe model.windowPositionY, F.toMaybe model.panIncrement ) of
                ( Just windowPositionY, Just panIncrement ) ->
                    render { model | windowPositionY = F.fromValue F.float False (windowPositionY + panIncrement) }

                _ ->
                    ( model, Cmd.none )

        ClickedDown ->
            case ( F.toMaybe model.windowPositionY, F.toMaybe model.panIncrement ) of
                ( Just windowPositionY, Just panIncrement ) ->
                    render { model | windowPositionY = F.fromValue F.float False (windowPositionY - panIncrement) }

                _ ->
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
                        |> Maybe.apply (F.toMaybe model.windowPositionX)
                        |> Maybe.apply (F.toMaybe model.windowPositionY)
                        |> Maybe.apply (F.toMaybe model.windowSize)
                        |> Maybe.apply (F.toMaybe model.zoomIncrement)
                        |> Maybe.join
            in
            case maybeWindow of
                Just { x, y, size } ->
                    render
                        { model
                            | windowPositionX = F.fromValue F.float False x
                            , windowPositionY = F.fromValue F.float False y
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
                        |> Maybe.apply (F.toMaybe model.windowPositionX)
                        |> Maybe.apply (F.toMaybe model.windowPositionY)
                        |> Maybe.apply (F.toMaybe model.windowSize)
                        |> Maybe.apply (F.toMaybe model.zoomIncrement)
            in
            case maybeWindow of
                Just { x, y, size } ->
                    render
                        { model
                            | windowPositionX = F.fromValue F.float False x
                            , windowPositionY = F.fromValue F.float False y
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
            , LabeledInput.view
                { id = "window-position-x"
                , label = "Window Position, x"
                , tipe = Input.Float { min = Nothing, max = Nothing }
                , isRequired = True
                , isDisabled = False
                , attrs = [ HA.placeholder "-25" ]
                , field = windowPositionX
                , onInput = InputWindowPositionX
                }
            , LabeledInput.view
                { id = "window-position-y"
                , label = "Window Position, y"
                , tipe = Input.Float { min = Nothing, max = Nothing }
                , isRequired = True
                , isDisabled = False
                , attrs = [ HA.placeholder "-25" ]
                , field = windowPositionY
                , onInput = InputWindowPositionY
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
            , LabeledInput.view
                { id = "fps"
                , label = "Frames per second (FPS)"
                , tipe = Input.Int { min = Just 1, max = Just 60 }
                , isRequired = True
                , isDisabled = False
                , attrs = [ HA.placeholder "1" ]
                , field = fps
                , onInput = InputFps
                }
            , LabeledInput.view
                { id = "ipf"
                , label = "Instructions per frame (IPF)"
                , tipe = Input.Int { min = Just 1, max = Just 60 }
                , isRequired = True
                , isDisabled = False
                , attrs = [ HA.placeholder "1" ]
                , field = ipf
                , onInput = InputIpf
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
                [ LabeledInput.view
                    { id = "pan-increment"
                    , label = "Pan Increment"
                    , tipe = Input.Int { min = Just 1, max = Just 1000000 }
                    , isRequired = True
                    , isDisabled = False
                    , attrs = [ HA.placeholder "1" ]
                    , field = panIncrement
                    , onInput = InputPanIncrement
                    }
                , H.text "Pan: "
                , H.button
                    [ HA.type_ "button"
                    , if F.isValid panIncrement then
                        HE.onClick ClickedLeft

                      else
                        HA.disabled True
                    ]
                    [ H.text "Left" ]
                , H.text " "
                , H.button
                    [ HA.type_ "button"
                    , if F.isValid panIncrement then
                        HE.onClick ClickedRight

                      else
                        HA.disabled True
                    ]
                    [ H.text "Right" ]
                , H.text " "
                , H.button
                    [ HA.type_ "button"
                    , if F.isValid panIncrement then
                        HE.onClick ClickedUp

                      else
                        HA.disabled True
                    ]
                    [ H.text "Up" ]
                , H.text " "
                , H.button
                    [ HA.type_ "button"
                    , if F.isValid panIncrement then
                        HE.onClick ClickedDown

                      else
                        HA.disabled True
                    ]
                    [ H.text "Down" ]
                ]
            , H.p [] <|
                [ LabeledInput.view
                    { id = "zoom-increment"
                    , label = "Zoom Increment"
                    , tipe = Input.Int { min = Just 1, max = Just 1000 }
                    , isRequired = True
                    , isDisabled = False
                    , attrs = [ HA.placeholder "1" ]
                    , field = zoomIncrement
                    , onInput = InputZoomIncrement
                    }
                , H.text "Zoom: "
                , H.button
                    [ HA.type_ "button"
                    , if isValidZoomIncrement { isZoomingIn = True, windowSize = windowSize, zoomIncrement = zoomIncrement } then
                        HE.onClick ClickedIn

                      else
                        HA.disabled True
                    ]
                    [ H.text "In" ]
                , H.text " "
                , H.button
                    [ HA.type_ "button"
                    , if isValidZoomIncrement { isZoomingIn = False, windowSize = windowSize, zoomIncrement = zoomIncrement } then
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
