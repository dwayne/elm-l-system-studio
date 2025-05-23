module Main exposing (main)

import Browser as B
import Html as H
import Renderer


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
    { renderer : Renderer.State
    }


init : () -> ( Model, Cmd msg )
init =
    always
        ( { renderer = Renderer.init }
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
view { renderer } =
    Renderer.view renderer
