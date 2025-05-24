{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE UndecidableInstances #-}

module Etna.Lib.Strategy.QuickCheck
  ( qcDefaults,
    qcMakeProp,
    qcMakeResult,
    qcRunArb,
    qcRunArb',
    backtrack,
  )
where

import Etna.Lib.Types
import Etna.Lib.Util (maxCap)
import System.IO.Silently (capture)
import Test.QuickCheck hiding (Result)
import qualified Test.QuickCheck as QC

-- To use QuickCheck, can just implement an Arbitrary instance
-- and call (qcRunArb qcDefaults [approach]), where approach
-- should be Naive if your generator does not necessarily generate 
-- inputs that satisfy the precondition, and Correct otherwise.

qcDefaults :: Args
qcDefaults = 
  -- By default, use timeout instead of max tests.
  stdArgs {maxSuccess = maxCap} 

qcMakeProp :: Approach -> Task a -> (a -> Property)
qcMakeProp Naive task =
  -- Filter based on precondition.
  uncurry (==>) . task
qcMakeProp Correct task =
  -- Only evaluate postcondition.
  QC.property . snd . task

qcMakeResult :: IO QC.Result -> IO Result
qcMakeResult ioresult = do
  (_, result) <- capture ioresult
  let (foundbug, output) =
        case result of
          Failure {failingTestCase = [ex]} -> (True, ex)
          NoExpectedFailure {} -> (True, "")
          r -> (False, "")
      discards = Just $ numDiscarded result
      passed = numTests result - (if foundbug then 1 else 0)
  return Result {..}

qcRunArb :: (Show a, Arbitrary a) => Args -> Approach -> Strategy a
qcRunArb args app = qcRunArb' args . qcMakeProp app

qcRunArb' :: (Show a, Arbitrary a) => Args -> (a -> Property) -> IO Result
qcRunArb' args prop = qcMakeResult $ quickCheckWithResult args prop

---------

type Freq a = [(Int, Gen (Maybe a))]

-- Based on QuickChick
backtrack :: Freq a -> Gen (Maybe a)
backtrack gs = go (sum $ map fst gs) gs
  where
    go _ [] = return Nothing
    go tot gs = do
      n <- chooseInt (1, tot)
      let (k, g, gs') = pickDrop n gs
      ma <- g
      case ma of
        Just _ -> return ma
        Nothing -> go (tot - k) gs'

    pickDrop :: Int -> Freq a -> (Int, Gen (Maybe a), Freq a)
    pickDrop _ [] = (0, return Nothing, [])
    pickDrop n ((k, g) : gs)
      | n <= k = (k, g, gs)
      | otherwise =
          let (k', g', gs') = pickDrop (n - k) gs
           in (k', g', (k, g) : gs')