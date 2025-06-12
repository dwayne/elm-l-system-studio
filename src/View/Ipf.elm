module View.Ipf exposing (Ipf, ViewOptions, init, update, view)

import Html as H
import View.Field as Field exposing (Field)


type alias Ipf =
    Field Int ()


maxIpf : Int
maxIpf =
    1000000


init : Int -> Ipf
init default =
    Field.init
        { default = default
        , toRaw = String.fromInt
        , toProcessed =
            \n ->
                if n >= 1 && n <= maxIpf then
                    Field.Default n

                else
                    Field.Invalid ()
        }


update : Field.Msg -> Ipf
update =
    Field.update
        { toProcessed =
            \raw ->
                case String.toInt raw of
                    Just n ->
                        if n >= 1 && n <= maxIpf then
                            Field.Valid n

                        else
                            Field.Invalid ()

                    Nothing ->
                        Field.Invalid ()
        }


type alias ViewOptions msg =
    { ipf : Ipf
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { ipf, onChange } =
    Field.view
        { id = "ipf"
        , label = "Instructions per frame (IPF)"
        , type_ =
            Field.Int
                { min = Just 1
                , max = Just maxIpf
                }
        , isRequired = True
        , placeholder = "1"
        , field = ipf
        , onChange = onChange
        }
