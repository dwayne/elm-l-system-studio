module Main exposing (main)

import Browser as B
import Data.Angle as Angle
import Data.Dictionary as Dictionary
import Data.Generator as Generator
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
            Generator.generate 4 rules axiom

        defaultSettings =
            Settings.default

        settings =
            { defaultSettings
                | startPosition = ( 350, 650 )
                , lineLength = 6
                , turningAngle = Angle.fromDegrees 60
            }

        instructions =
            Translator.translate Dictionary.default settings chars
    in
    always
        ( { renderer = Renderer.init instructions }
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
                        ChangedRenderer
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
view =
    always <|
        Canvas.view
            { id = "canvas"
            , width = 1000
            , height = 1000
            }
