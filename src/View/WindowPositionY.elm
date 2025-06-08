module View.WindowPositionY exposing (ViewOptions, WindowPositionY, init, update, view)

import Html as H
import View.Field as Field
import View.FloatField as FloatField exposing (FloatField)


type alias WindowPositionY =
    FloatField


init : Float -> WindowPositionY
init =
    FloatField.init


update : Field.Msg -> WindowPositionY
update =
    FloatField.update


type alias ViewOptions msg =
    { windowPositionY : WindowPositionY
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { windowPositionY, onChange } =
    FloatField.view
        { id = "window-position-y"
        , label = "Window Position, y"
        , isRequired = True
        , placeholder = "-25"
        , field = windowPositionY
        , onChange = onChange
        }
