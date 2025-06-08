module View.WindowSize exposing (ViewOptions, WindowSize, init, update, view)

import Html as H
import View.Field as Field
import View.NonNegativeFloatField as NonNegativeFloatField exposing (NonNegativeFloatField)


type alias WindowSize =
    NonNegativeFloatField


init : Float -> WindowSize
init =
    NonNegativeFloatField.init


update : Field.Msg -> WindowSize
update =
    NonNegativeFloatField.update


type alias ViewOptions msg =
    { windowSize : WindowSize
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { windowSize, onChange } =
    NonNegativeFloatField.view
        { id = "window-size"
        , label = "Window Size"
        , isRequired = True
        , placeholder = "100"
        , field = windowSize
        , onChange = onChange
        }
