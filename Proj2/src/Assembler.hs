module Assembler where

import Data.List
import Data.Maybe

import AssemblerSpec

-- type Stack = [Show]

data Literal = Int Integer | Bool Bool
  
instance Show Literal where
  show (Bool b) = show b
  show (Int i) = show i

instance Eq Literal where
  (Bool a) == (Bool b) = a == b
  (Int a) == (Int b) = a == b

type Stack = [Literal]

type State = [(String, Literal)]

createEmptyStack :: Stack
createEmptyStack = []

createEmptyState :: State
createEmptyState = []

stack2Str :: Stack -> String
stack2Str s = intercalate "," $ map show s

state2Str :: State -> String
state2Str s = intercalate "," $ map (\(key, value) -> key ++ "=" ++ show value) $ sortOn fst s

fetchHelper :: String -> State -> Maybe Literal
fetchHelper _ [] = Nothing
fetchHelper target ((key, value):pairs)
  | target == key = Just value
  | otherwise     = fetchHelper target pairs

storeHelperRecursive :: String -> Literal -> State -> State -> State
storeHelperRecursive _ _ [] accum = accum
storeHelperRecursive key value ((iterkey, itervalue):pairs) accum
  | key == iterkey  = storeHelperRecursive key value pairs accum ++ [(key, value)]
  | otherwise       = storeHelperRecursive key value pairs accum ++ [(iterkey, itervalue)]

storeHelper :: String -> Literal -> State -> State
storeHelper key value state =
  case fetchHelper key state of
    Just _  -> storeHelperRecursive key value state []
    Nothing -> state ++ [(key, value)]

ensureInteger :: Literal -> Integer
ensureInteger l = case l of
                    Int i -> i
                    otherwise -> error "Run-time error" 

ensureBool :: Literal -> Bool
ensureBool l = case l of
                    Bool b -> b
                    otherwise -> error "Run-time error" 

run :: (Code, Stack, State) -> (Code, Stack, State)
run ([], stack, state) = ([], stack, state)
run (inst:code, stack, state) = run(newcode, newstack, newstate)
  where
    (newcode, newstack, newstate) = 
      let tail2 = drop 2 stack
          tail1 = drop 1 stack
          op1 = head stack
          op2 = head tail1
          (int1, int2) = (ensureInteger op1, ensureInteger op2)
          (bool1, bool2) = (ensureBool op1, ensureBool op2)
      in case inst of
        Push i      ->      (code, (Int i):stack,                    state)
        Add         ->      (code, Int(int1 + int2):tail2,           state)
        Mult        ->      (code, Int(int1 * int2):tail2,           state)
        Sub         ->      (code, Int(int1 - int2):tail2,           state)
        Tru         ->      (code, (Bool True):stack,                state)
        Fals        ->      (code, (Bool False):stack,               state)
        Equ         ->      (code, Bool(op1 == op2):tail2,           state)
        Le          ->      (code, Bool(int1 <= int2):tail2,         state)
        And         ->      (code, Bool(bool1 && bool2):tail2,       state)
        Neg         ->      (code, Bool(not bool1):tail1,            state)
        Fetch s     ->      (code, retrieved:stack,                  state)
                            where
                              retrieved =
                                case fetchHelper s state of
                                  Just literal -> literal
                                  Nothing -> error "Run-time error"
        Store s     ->      (code, tail1, storeHelper s (head stack) state)
        Noop        ->      (code, stack,                            state)
        Branch t f  ->      (branch ++ code, tail1,                  state)
                            where branch = if bool1 then t else f
        Loop c1 c2  ->      (translation ++ code, stack,             state)
                            where translation = c1 ++ [Branch(c2 ++ [Loop c1 c2]) [Noop]]
