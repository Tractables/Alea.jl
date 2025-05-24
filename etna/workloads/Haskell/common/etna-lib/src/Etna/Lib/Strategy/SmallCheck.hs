{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RecordWildCards #-}

module Etna.Lib.Strategy.SmallCheck (scDefaults, scRun) where

import Data.IORef
import Data.Maybe (isJust)
import Etna.Lib.Types
import Etna.Lib.Util (maxCap)
import Test.SmallCheck
import Test.SmallCheck.Drivers
import Test.SmallCheck.Series

type Args = (Depth, Cap)

scDefaults :: Args
scDefaults = (maxCap, maxCap)

makeProp :: Approach -> Task a -> (a -> Property IO)
makeProp Naive task =
  -- Filter based on precondition.
  test . uncurry (==>) . task
makeProp Correct task =
  -- Only evaluate postcondition.
  test . snd . task

scRun :: (Show a, Serial IO a) => Approach -> Args -> Strategy a
scRun app (depth, cap) task = do
  good <- newIORef 0
  bad <- newIORef 0
  final <- smallCheckWithHook depth (update good bad) prop

  let (foundbug, output) = case final of
        Nothing -> (False, "")
        Just (CounterExample (ex : _) _) -> (True, ex)
        Just _ -> (True, "")
  passed <- (\i -> i - if foundbug then 1 else 0) <$> readIORef good
  discards <- Just <$> readIORef bad
  return Result {..}
  where
    prop = over (limit cap series) (makeProp app task)

    update good bad = \case
      GoodTest -> modifyIORef good (+ 1)
      BadTest -> modifyIORef bad (+ 1)