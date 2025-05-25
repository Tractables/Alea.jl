{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE RecordWildCards #-}

module Etna.Lib.Util
  ( maxCap,
    readEnv,
    parseExpArgs,
    allProps,
    mapExample,
    mapExample',
  )
where

import Etna.Lib.Types (ExpArgs, Result (..))
import Data.Aeson (decode)
import Data.Char (isAlphaNum, isSpace)
import Data.List (elemIndex, isPrefixOf, nub)
import Data.String (fromString)
import GHC.IO (unsafePerformIO)
import System.Environment (getEnv)

maxCap :: Int
maxCap =
  -- Divide by some large enough constant to prevent integer overflow.
  maxBound `div` 100

readEnv :: Read a => String -> a
readEnv s = read $ unsafePerformIO $ getEnv s

parseExpArgs :: String -> ExpArgs
parseExpArgs s = case decode . fromString $ s of
  Nothing -> error $ "Could not parse " ++ s
  Just a -> a

-- Closely adapted from Test.QuickCheck.All
allProps :: String -> IO [String]
allProps file = do
  ls <- lines <$> readFile file
  return $ nub $ filter ("prop_" `isPrefixOf`) $ prefixes ls
  where
    prefixes =
      map
        ( takeWhile (\c -> isAlphaNum c || c == '_' || c == '\'')
            . dropWhile (\c -> isSpace c || c == '>')
        )

parseTuple :: Read b => String -> b
parseTuple s@('(' : s') =
  case elemIndex ',' s' of
    Just i -> read $ take i s'
    Nothing -> read s
parseTuple s = read s

mapExample :: Read b => (b -> String) -> IO Result -> IO Result
mapExample f ir = do
  r@Result {output, ..} <- ir
  if null output
    then return r
    else return Result {output = f (parseTuple output), ..}

mapExample' :: (String -> String) -> IO Result -> IO Result
mapExample' f ir = do
  r@Result {output, ..} <- ir
  if null output
    then return r
    else return Result {output = f output, ..}