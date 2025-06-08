module View.Input.Iterations exposing (Iterations, ViewOptions, init, update, view)

import Html as H
import View.Field as Field exposing (Field)


type alias Iterations =
    Field Int ()


init : Int -> Iterations
init default =
    Field.init
        { default = default
        , toRaw = String.fromInt
        , toProcessed =
            \n ->
                if n >= 0 then
                    Field.Default n

                else
                    Field.Invalid ()
        }


update : Field.Msg -> Iterations
update =
    Field.update
        { toProcessed =
            \raw ->
                case String.toInt raw of
                    Just n ->
                        if n >= 0 then
                            Field.Valid n

                        else
                            Field.Invalid ()

                    Nothing ->
                        Field.Invalid ()
        }


type alias ViewOptions msg =
    { iterations : Iterations
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { iterations, onChange } =
    Field.view
        { id = "iterations"
        , label = "Iterations"
        , type_ =
            Field.Number
                { min = Just 0
                , max = Nothing
                }
        , isRequired = True
        , placeholder = "3"
        , field = iterations
        , onChange = onChange
        }
