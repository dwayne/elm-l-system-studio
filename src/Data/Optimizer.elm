module Data.Optimizer exposing (simplify)

import Data.Instruction exposing (Instruction(..))
import Lib.Sequence as Sequence exposing (Sequence(..))


simplify : Sequence Instruction -> Sequence Instruction
simplify =
    simplifyHelper Nothing Nothing


simplifyHelper : Maybe Reason -> Maybe Instruction -> Sequence Instruction -> Sequence Instruction
simplifyHelper maybePrevReason maybePrev instructions =
    case instructions of
        Empty ->
            case maybePrev of
                Just prev ->
                    Cons prev Empty

                Nothing ->
                    Empty

        Cons curr rest ->
            case maybePrev of
                Just prev ->
                    case combine maybePrevReason prev curr of
                        Just ( newReason, newInstruction ) ->
                            simplifyHelper (Just newReason) (Just newInstruction) rest

                        Nothing ->
                            Cons prev (simplifyHelper Nothing (Just curr) rest)

                Nothing ->
                    simplifyHelper maybePrevReason (Just curr) rest

        Thunk t ->
            Thunk (\_ -> simplifyHelper maybePrevReason maybePrev (t ()))


type Reason
    = BackToBackMoveTo
    | SameX
    | SameY


combine : Maybe Reason -> Instruction -> Instruction -> Maybe ( Reason, Instruction )
combine maybeReason a b =
    case ( a, b ) of
        ( MoveTo _, MoveTo _ ) ->
            Just ( BackToBackMoveTo, b )

        ( LineTo l1, LineTo l2 ) ->
            if l1.lineWidth == l2.lineWidth then
                if canCombineOnX maybeReason && l1.position.x == l2.position.x then
                    Just ( SameX, b )

                else if canCombineOnY maybeReason && l1.position.y == l2.position.y then
                    Just ( SameY, b )

                else
                    Nothing

            else
                Nothing

        _ ->
            Nothing


canCombineOnX : Maybe Reason -> Bool
canCombineOnX maybeReason =
    maybeReason == Nothing || maybeReason == justSameX


canCombineOnY : Maybe Reason -> Bool
canCombineOnY maybeReason =
    maybeReason == Nothing || maybeReason == justSameY


justSameX : Maybe Reason
justSameX =
    Just SameX


justSameY : Maybe Reason
justSameY =
    Just SameY
