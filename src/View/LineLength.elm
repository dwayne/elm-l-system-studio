module View.LineLength exposing (LineLength, ViewOptions, init, update, view)

import Html as H
import View.Field as Field
import View.NonNegativeFloatField as NonNegativeFloatField exposing (NonNegativeFloatField)


type alias LineLength =
    NonNegativeFloatField


init : Float -> LineLength
init =
    NonNegativeFloatField.init


update : Field.Msg -> LineLength
update =
    NonNegativeFloatField.update


type alias ViewOptions msg =
    { lineLength : LineLength
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { lineLength, onChange } =
    NonNegativeFloatField.view
        { id = "line-length"
        , label = "Line Length"
        , isRequired = True
        , placeholder = "1"
        , field = lineLength
        , onChange = onChange
        }
