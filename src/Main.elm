module Main exposing (main)

import Browser as B
import Canvas
import Html as H


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
    { canvas : Canvas.State
    }


init : () -> ( Model, Cmd msg )
init =
    always
        ( { canvas = Canvas.init }
        , Cmd.none
        )



-- UPDATE


type Msg
    = ChangedCanvas Canvas.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedCanvas subMsg ->
            let
                ( canvas, cmd ) =
                    Canvas.update
                        ChangedCanvas
                        subMsg
                        model.canvas
            in
            ( { model | canvas = canvas }
            , cmd
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Canvas.subscriptions ChangedCanvas model.canvas



-- VIEW


view : Model -> H.Html msg
view =
    always Canvas.view
