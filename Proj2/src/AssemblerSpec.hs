module AssemblerSpec where

-- Do not modify our definition of Inst and Code
data Inst =
  Push Integer | Add | Mult | Sub | Tru | Fals | Equ | Le | And | Neg | Fetch String | Store String | Noop |
  Branch Code Code | Loop Code Code
  deriving Show
type Code = [Inst]

-- createEmptyStack :: Stack
-- createEmptyStack = undefined -- TODO, Uncomment the function signature after defining Stack

-- stack2Str :: Stack -> String
-- stack2Str = undefined -- TODO, Uncomment all the other function type declarations as you implement them

-- createEmptyState :: State
-- createEmptyState = undefined -- TODO, Uncomment the function signature after defining State

-- state2Str :: State -> String
-- state2Str = undefined -- TODO

-- run :: (Code, Stack, State) -> (Code, Stack, State)
-- run = undefined -- TODO