module Spec where

import Etna.Lib
import Data.Maybe (fromJust, isJust)
import Impl
import Type
import Util

prop_SinglePreserve :: Task Term
prop_SinglePreserve t =
  isJust mty --> mtypeCheck (pstep t) (fromJust mty)
  where
    mty = getTyp 40 Empty t

prop_MultiPreserve :: Task Term
prop_MultiPreserve t =
  isJust mty --> mtypeCheck (multistep 40 pstep t) (fromJust mty)
  where
    mty = getTyp 40 Empty t

mtypeCheck :: Maybe Term -> Typ -> Bool
mtypeCheck (Just e) t = typeCheck Empty e t
mtypeCheck Nothing _ = True -- TODO: add back discards

sizeFSub :: Term -> Int
sizeFSub = go
  where
    go :: Term -> Int
    go (Abs _ t) = 1 + go t
    go (App t1 t2) = 1 + go t1 + go t2
    go (TAbs _ t) = 1 + go t
    go (TApp t _) = 1 + go t
    go _ = 1