module View.Fps exposing (Fps, ViewOptions, init, update, view)

import Html as H
import View.Field as Field exposing (Field)


type alias Fps =
    Field Int ()


init : Int -> Fps
init default =
    Field.init
        { default = default
        , toRaw = String.fromInt
        , toProcessed =
            \n ->
                if n >= 1 && n <= 60 then
                    Field.Default n

                else
                    Field.Invalid ()
        }


update : Field.Msg -> Fps
update =
    Field.update
        { toProcessed =
            \raw ->
                case String.toInt raw of
                    Just n ->
                        if n >= 1 && n <= 60 then
                            Field.Valid n

                        else
                            Field.Invalid ()

                    Nothing ->
                        Field.Invalid ()
        }


type alias ViewOptions msg =
    { fps : Fps
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { fps, onChange } =
    Field.view
        { id = "fps"
        , label = "Frames per second (FPS)"
        , type_ =
            Field.Int
                { min = Just 1
                , max = Just 60
                }
        , isRequired = True
        , placeholder = "1"
        , field = fps
        , onChange = onChange
        }
