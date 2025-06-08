module View.LineLengthScaleFactor exposing (LineLengthScaleFactor, ViewOptions, init, update, view)

import Html as H
import View.Field as Field
import View.NonNegativeFloatField as NonNegativeFloatField exposing (NonNegativeFloatField)


type alias LineLengthScaleFactor =
    NonNegativeFloatField


init : Float -> LineLengthScaleFactor
init =
    NonNegativeFloatField.init


update : Field.Msg -> LineLengthScaleFactor
update =
    NonNegativeFloatField.update


type alias ViewOptions msg =
    { lineLengthScaleFactor : LineLengthScaleFactor
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { lineLengthScaleFactor, onChange } =
    NonNegativeFloatField.view
        { id = "line-length-scale-factor"
        , label = "Line Length Scale Factor"
        , isRequired = True
        , placeholder = "1"
        , field = lineLengthScaleFactor
        , onChange = onChange
        }
