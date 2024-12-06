-- Compiler.hs
module Compiler where

import Types
import Assembler
import AssemblerSpec

compA :: Aexp -> Code
compA (NumA n) = [Push n]
compA (VarA x) = [Fetch x]
compA (AddA a1 a2) = compA a1 ++ compA a2 ++ [Add]
compA (SubA a1 a2) = compA a1 ++ compA a2 ++ [Sub]
compA (MultA a1 a2) = compA a1 ++ compA a2 ++ [Mult]
compA (ParensA a:rest) = compA a ++ compA rest

compB :: Bexp -> Code
compB TrueB = [Tru]
compB FalseB = [Fals]
compB (EqA a1 a2) = compA a1 ++ compA a2 ++ [Equ]
compB (EqB b1 b2) = compB b1 ++ compB b2 ++ [Equ]
compB (LeA a1 a2) = compA a1 ++ compA a2 ++ [Le]
compB (AndB b1 b2) = compB b1 ++ compB b2 ++ [And]
compB (NotB b) = compB b ++ [Neg]

compile :: [Stm] -> Code
compile [] = []
compile (stm:rest) = inst ++ compile rest
  where
    inst =
      case stm of
        Assign name value -> compA value ++ [Store name]
        If cond body -> compB cond ++ compile body
        While cond body -> [Loop (compB cond) (compile body)]
        Seq stm -> compile stm
