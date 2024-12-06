-- Types.hs
module Types where

-- Arithmetic Expressions
data Aexp =
  VarA String | NumA Integer | AddA Aexp Aexp | SubA Aexp Aexp | MultA Aexp Aexp | ParensA Aexp
  deriving Show

-- Boolean Expressions
data Bexp = TrueB | FalseB | NotB Bexp | LeA Aexp Aexp | EqA Aexp Aexp | EqB Bexp Bexp | AndB Bexp Bexp
  deriving Show

-- Statements
data Stm = Assign String Aexp | Seq [Stm] | If Bexp [Stm] | While Bexp [Stm]
  deriving Show
