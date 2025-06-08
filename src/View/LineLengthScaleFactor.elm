module View.LineLengthScaleFactor exposing (LineLengthScaleFactor, ViewOptions, init, update, view)

import Html as H
import View.Field as Field exposing (Field)


type alias LineLengthScaleFactor =
    Field Float ()


init : Float -> LineLengthScaleFactor
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


update : Field.Msg -> LineLengthScaleFactor
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
    { lineLengthScaleFactor : LineLengthScaleFactor
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { lineLengthScaleFactor, onChange } =
    Field.view
        { id = "line-length-scale-factor"
        , label = "Line Length Scale Factor"
        , type_ =
            Field.Float
                { min = Just 0
                }
        , isRequired = True
        , placeholder = "1"
        , field = lineLengthScaleFactor
        , onChange = onChange
        }
