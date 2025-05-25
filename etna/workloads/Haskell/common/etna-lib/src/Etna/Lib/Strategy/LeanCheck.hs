{-# LANGUAGE RecordWildCards #-}

module Etna.Lib.Strategy.LeanCheck (lcRun) where

import Etna.Lib.Types
import Data.Char (isDigit)
import Data.List (find, isInfixOf)
import Data.Maybe (fromJust)
import System.IO.Silently (capture_)
import Test.LeanCheck
import Text.Regex.TDFA

makeProp :: Approach -> Task a -> (a -> Bool)
makeProp Naive task =
  -- Filter based on precondition.
  uncurry (==>) . task
makeProp Correct task =
  -- Only evaluate postcondition.
  snd . task

lcRun :: (Show a, Listable a) => Approach -> Int -> Strategy a
lcRun app cap task = do
  out <- capture_ $ checkFor cap prop
  let foundbug = "Failed" `isInfixOf` out
      passed = getNumTests out - if foundbug then 1 else 0
      discards = Nothing -- does not count discards
      output = case lines out of
        (_ : o : _) -> o
        _ -> ""
  return Result {..}
  where
    prop = makeProp app task

    getNumTests :: String -> Int
    getNumTests out = read $ extractGroup out "([0-9]+) test"

    extractGroup :: String -> String -> String
    extractGroup out regex =
      let matches = out =~ regex :: [[String]]
       in head matches !! 1

-- TODO: there should be a way of optionally counting discards that doesn't affect the time