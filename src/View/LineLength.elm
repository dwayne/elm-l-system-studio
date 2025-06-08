module View.LineLength exposing (LineLength, ViewOptions, init, update, view)

import Html as H
import View.Field as Field exposing (Field)


type alias LineLength =
    Field Float ()


init : Float -> LineLength
init default =
    Field.init
        { default = default
        , toRaw = String.fromFloat
        , toProcessed =
            \f ->
                if f >= 0 then
                    Field.Default f

                else
                    Field.Invalid ()
        }


update : Field.Msg -> LineLength
update =
    Field.update
        { toProcessed =
            \raw ->
                case String.toFloat raw of
                    Just f ->
                        if f >= 0 then
                            Field.Valid f

                        else
                            Field.Invalid ()

                    Nothing ->
                        Field.Invalid ()
        }


type alias ViewOptions msg =
    { lineLength : LineLength
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { lineLength, onChange } =
    Field.view
        { id = "line-length"
        , label = "Line Length"
        , type_ =
            Field.Float
                { min = Just 0
                }
        , isRequired = True
        , placeholder = "1"
        , field = lineLength
        , onChange = onChange
        }
