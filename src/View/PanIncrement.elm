module View.PanIncrement exposing (PanIncrement, ViewOptions, init, update, view)

import Html as H
import View.Field as Field exposing (Field)


type alias PanIncrement =
    Field Float ()


minPanIncrement : Float
minPanIncrement =
    1


maxPanIncrement : Float
maxPanIncrement =
    1000000


init : Float -> PanIncrement
init default =
    Field.init
        { default = default
        , toRaw = String.fromFloat
        , toProcessed =
            \f ->
                if f >= minPanIncrement && f <= maxPanIncrement then
                    Field.Default f

                else
                    Field.Invalid ()
        }


update : Field.Msg -> PanIncrement
update =
    Field.update
        { toProcessed =
            \raw ->
                case String.toFloat raw of
                    Just f ->
                        if f >= minPanIncrement && f <= maxPanIncrement then
                            Field.Valid f

                        else
                            Field.Invalid ()

                    Nothing ->
                        Field.Invalid ()
        }


type alias ViewOptions msg =
    { panIncrement : PanIncrement
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { panIncrement, onChange } =
    Field.view
        { id = "panIncrement"
        , label = "Pan Increment"
        , type_ =
            Field.Float
                { min = Just minPanIncrement
                , max = Just maxPanIncrement
                }
        , isRequired = True
        , placeholder = String.fromFloat minPanIncrement
        , field = panIncrement
        , onChange = onChange
        }
