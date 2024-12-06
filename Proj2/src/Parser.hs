-- Parser.hs
module Parser where

import Data.List (isInfixOf, isPrefixOf)
import Data.Either (fromRight)
import Text.Parsec

import Assembler
import AssemblerSpec
import Types

keywords :: [String]
keywords = ["if", "then", "else", "do", "and", "not", "while"]

validVariableName :: String -> Bool
validVariableName str@(fc:rest) = not (any (`isInfixOf` str) keywords)

lexeme :: Parsec String s u -> Parsec String s u
lexeme p = spaces *> p <* spaces

termA :: Parsec String s Aexp
termA = num <|> var <|> parens

termB :: Parsec String s Bexp
termB = try bool <|> try le <|> try eqA <|> try notB

num :: Parsec String s Aexp
num = (NumA . read) <$> lexeme (many1 digit)

var :: Parsec String s Aexp
var = VarA <$> lexeme ((:) <$> lower <*> many alphaNum)

opA :: Parsec String s Aexp
opA = lexeme termA `chainl1` operator
      where operator = AddA <$ lexeme (char '+') <|>
                       SubA <$ lexeme (char '-') <|>
                       MultA <$ lexeme (char '*')

parens :: Parsec String s Aexp
parens = ParensA <$> (lexeme (char '(') *> opA <* lexeme (char ')'))

le :: Parsec String s Bexp
le = LeA <$> opA <* lexeme (string "<=") <*> opA

eqA :: Parsec String s Bexp
eqA = EqA <$> opA <* lexeme (string "==") <*> opA

notB :: Parsec String s Bexp
notB = NotB <$> (lexeme (string "not") *> termB)

opB :: Parsec String s Bexp
opB = termB `chainl1` operator
      where operator = EqB <$ lexeme (string "=") <|>
                       AndB <$ lexeme (string "and")

bool :: Parsec String s Bexp
bool = TrueB <$ (lexeme (string "True")) <|>
       FalseB <$ lexeme (string "False")

nextStm :: String -> String
nextStm "" = ""
nextStm (';':p:rest) = dropWhile (== ' ') (if p == ')' then drop 1 rest else (p:rest))
nextStm (_:rest) = nextStm rest


skipIf :: Parsec String s String
skipIf = (manyTill anyChar (string "then")) *> lexeme (many anyChar) 

skipWhere :: Parsec String s String
skipWhere = (manyTill anyChar (string "do")) *> lexeme (many anyChar) 

parserHelper :: String -> [Stm] -> [Stm]
parserHelper "" accum = accum
parserHelper s@('i':'f':_) accum = parserHelper (nextStm s) (accum ++ stm)
                       where stm = [If cond body]
                             cond = (fromRight (error "Run-time error") (parse (lexeme (string "if") *> opB <* lexeme (string "then")) "" s))
                             temp = (fromRight (error "Run-time error") (parse (lexeme skipIf) "" s))
                             body = if (isPrefixOf "(" temp) then parser (takeWhile (/= ')') (drop 1 temp)) else parser (takeWhile (/= ';') temp)

parserHelper s@('w':'h':'i':'l':'e':_) accum = parserHelper "" (accum ++ stm)
                       where stm = [While cond body]
                             cond = (fromRight (error "Run-time error") (parse (lexeme (string "while") *> opB <* lexeme (string "do")) "" s))
                             temp = (fromRight (error "Run-time error") (parse (lexeme skipWhere) "" s))
                             body = if (isPrefixOf "(" temp) then parser (takeWhile (/= ')') (drop 1 temp)) else parser (takeWhile (/= ';') temp)

parserHelper s accum = parserHelper (nextStm s) (accum ++ stm)
                       where 
                        name = 
                          case fromRight (error "Run-time error") (parse (lexeme var ) "" s) of
                            VarA str -> str
                        stm = [Assign name (fromRight (error "Run-time error") (parse ((lexeme var) *> lexeme (string ":=") *> lexeme opA) "" s))]

parser :: String -> [Stm]
parser s = parserHelper s []
