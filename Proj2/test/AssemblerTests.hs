module Main where

import AssemblerSpec
import Assembler

-- To help you test your assembler
testAssembler :: Code -> (String, String)
testAssembler code = (stack2Str stack, state2Str state)
  where (_,stack,state) = run(code, createEmptyStack, createEmptyState)

main :: IO ()
main = do
-- Examples:
  print $ testAssembler [Push 10,Push 4,Push 3,Sub,Mult] == ("-10","")
  print $ testAssembler [Fals,Push 3,Tru,Store "var",Store "a", Store "someVar"] == ("","a=3,someVar=False,var=True")
  print $ testAssembler [Fals,Store "var",Fetch "var"] == ("False","var=False")
  print $ testAssembler [Push (-20),Tru,Fals] == ("False,True,-20","")
  print $ testAssembler [Push (-20),Tru,Tru,Neg] == ("False,True,-20","")
  print $ testAssembler [Push (-20),Tru,Tru,Neg,Equ] == ("False,-20","")
  print $ testAssembler [Push (-20),Push (-21), Le] == ("True","")
  print $ testAssembler [Push 5,Store "x",Push 1,Fetch "x",Sub,Store "x"] == ("","x=4")
  print $ testAssembler [Push 10,Store "i",Push 1,Store "fact",Loop [Push 1,Fetch "i",Equ,Neg] [Fetch "i",Fetch "fact",Mult,Store "fact",Push 1,Fetch "i",Sub,Store "i"]] == ("","fact=3628800,i=1")
-- If you test:
  -- print $ testAssembler [Push 1,Push 2,And]
-- You should get an exception with the string: "Run-time error"
-- If you test:
  -- print $ testAssembler [Tru,Tru,Store "y", Fetch "x",Tru]
-- You should get an exception with the string: "Run-time error"