module View.WindowPositionX exposing (ViewOptions, WindowPositionX, init, update, view)

import Html as H
import View.Field as Field
import View.FloatField as FloatField exposing (FloatField)


type alias WindowPositionX =
    FloatField


init : Float -> WindowPositionX
init =
    FloatField.init


update : Field.Msg -> WindowPositionX
update =
    FloatField.update


type alias ViewOptions msg =
    { windowPositionX : WindowPositionX
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { windowPositionX, onChange } =
    FloatField.view
        { id = "window-position-x"
        , label = "Window Position, x"
        , isRequired = True
        , placeholder = "-25"
        , field = windowPositionX
        , onChange = onChange
        }
