module View.ZoomIncrement exposing (ViewOptions, ZoomIncrement, init, update, view)

import Html as H
import View.Field as Field exposing (Field)


type alias ZoomIncrement =
    Field Float ()


minZoomIncrement : Float
minZoomIncrement =
    1


maxZoomIncrement : Float
maxZoomIncrement =
    1000


init : Float -> ZoomIncrement
init default =
    Field.init
        { default = default
        , toRaw = String.fromFloat
        , toProcessed =
            \f ->
                if f >= minZoomIncrement && f <= maxZoomIncrement then
                    Field.Default f

                else
                    Field.Invalid ()
        }


update : Field.Msg -> ZoomIncrement
update =
    Field.update
        { toProcessed =
            \raw ->
                case String.toFloat raw of
                    Just f ->
                        if f >= minZoomIncrement && f <= maxZoomIncrement then
                            Field.Valid f

                        else
                            Field.Invalid ()

                    Nothing ->
                        Field.Invalid ()
        }


type alias ViewOptions msg =
    { zoomIncrement : ZoomIncrement
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { zoomIncrement, onChange } =
    Field.view
        { id = "zoomIncrement"
        , label = "Zoom Increment"
        , type_ =
            Field.Float
                { min = Just minZoomIncrement
                , max = Just maxZoomIncrement
                }
        , isRequired = True
        , placeholder = String.fromFloat minZoomIncrement
        , field = zoomIncrement
        , onChange = onChange
        }
