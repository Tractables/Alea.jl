module Spec where

import Etna.Lib
import Data.Maybe (fromJust, isJust)
import Impl

prop_SinglePreserve :: Task Expr
prop_SinglePreserve e =
  isJust mt --> mtypeCheck (pstep e) (fromJust mt)
  where
    mt = getTyp [] e

prop_MultiPreserve :: Task Expr
prop_MultiPreserve e =
  isJust mt --> mtypeCheck (multistep 40 pstep e) (fromJust mt)
  where
    mt = getTyp [] e

mtypeCheck :: Maybe Expr -> Typ -> Bool
mtypeCheck (Just e) t = typeCheck [] e t
mtypeCheck Nothing _ = True -- TODO: add back discards

---

sizeSTLC :: Expr -> Int
sizeSTLC = go
  where
    go :: Expr -> Int
    go (Abs _ e) = 1 + go e
    go (App e1 e2) = 1 + go e1 + go e2
    go _ = 1