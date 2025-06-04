module Data.SvgRenderer3 exposing (Msg, Renderer, init, subscriptions, update, view)

--
-- This example confirms that the "too much recursion" error has nothing to do with my Lib.Sequence data structure.
--
-- It seems to happen when I reach a certain number of lines (4388 nodes) in the DOM.
--

import Browser.Events as BE
import Html as H
import Svg as S
import Svg.Attributes as SA
import Svg.Keyed as SK


type Renderer msg
    = Renderer (State msg)


type alias State msg =
    { id : Int
    , svgs : List ( String, S.Svg msg )
    }


init : Renderer msg
init =
    Renderer
        { id = 1
        , svgs = []
        }


line : Int -> Int -> S.Svg msg
line x y =
    S.line
        [ SA.x1 "0"
        , SA.y1 "0"
        , SA.x2 (String.fromInt x)
        , SA.y2 (String.fromInt y)
        , SA.stroke "black"
        , SA.strokeWidth "2"
        ]
        []


type Msg
    = GotAnimationFrame Float


update : Msg -> Renderer msg -> Renderer msg
update msg (Renderer state) =
    case msg of
        GotAnimationFrame delta ->
            Renderer
                { state
                    | id = state.id + 1
                    , svgs = ( String.fromInt state.id, line state.id state.id ) :: state.svgs
                }


subscriptions : (Msg -> msg) -> Renderer msg -> Sub msg
subscriptions onChange _ =
    BE.onAnimationFrameDelta (onChange << GotAnimationFrame)


type alias ViewOptions msg =
    { width : Int
    , height : Int
    , renderer : Renderer msg
    }


view : ViewOptions msg -> H.Html msg
view { width, height, renderer } =
    let
        svgs =
            case renderer of
                Renderer state ->
                    state.svgs

        widthAsString =
            String.fromInt width

        heightAsString =
            String.fromInt height
    in
    S.svg
        [ SA.class "canvas"
        , SA.width widthAsString
        , SA.height heightAsString
        , SA.viewBox ("0 0 " ++ widthAsString ++ " " ++ heightAsString)
        ]
        [ SK.node "g" [] svgs
        ]
