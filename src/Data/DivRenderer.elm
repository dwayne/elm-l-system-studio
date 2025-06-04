module Data.DivRenderer exposing (Msg, Renderer, init, subscriptions, update, view)

--
-- Is it only SVG related? Or do we run into problems with lots of HTML nodes as well?
--
-- We do. We run into the "too much recursion" error with a certain number (6921 nodes) of HTML nodes as well.
--

import Browser.Events as BE
import Html as H
import Html.Keyed as HK


type Renderer msg
    = Renderer (State msg)


type alias State msg =
    { id : Int
    , divs : List ( String, H.Html msg )
    }


init : Renderer msg
init =
    Renderer
        { id = 1
        , divs = []
        }


type Msg
    = GotAnimationFrame Float


update : Msg -> Renderer msg -> Renderer msg
update msg (Renderer state) =
    case msg of
        GotAnimationFrame delta ->
            Renderer
                { state
                    | id = state.id + 1
                    , divs = ( String.fromInt state.id, H.div [] [ H.text (String.fromInt state.id) ] ) :: state.divs
                }


subscriptions : (Msg -> msg) -> Renderer msg -> Sub msg
subscriptions onChange _ =
    BE.onAnimationFrameDelta (onChange << GotAnimationFrame)


type alias ViewOptions msg =
    { renderer : Renderer msg
    }


view : ViewOptions msg -> H.Html msg
view { renderer } =
    let
        divs =
            case renderer of
                Renderer state ->
                    state.divs
    in
    HK.node "div" [] divs
