module View.Axiom exposing (Axiom, ViewOptions, init, update, view)

import Html as H
import View.Field as Field exposing (Field)


type alias Axiom =
    Field String ()


init : String -> Axiom
init default =
    Field.init
        { default = default
        , toRaw = identity
        , toProcessed =
            \s ->
                let
                    t =
                        String.trim s
                in
                if String.isEmpty t then
                    Field.Invalid ()

                else
                    Field.Default s
        }


update : Field.Msg -> Axiom
update =
    Field.update
        { toProcessed =
            \s ->
                let
                    t =
                        String.trim s
                in
                if String.isEmpty t then
                    Field.Invalid ()

                else
                    Field.Valid s
        }


type alias ViewOptions msg =
    { axiom : Axiom
    , onChange : Field.Msg -> msg
    }


view : ViewOptions msg -> H.Html msg
view { axiom, onChange } =
    Field.view
        { id = "axiom"
        , label = "Axiom"
        , type_ = Field.Text
        , isRequired = True
        , placeholder = "F+F+F+F"
        , field = axiom
        , onChange = onChange
        }
