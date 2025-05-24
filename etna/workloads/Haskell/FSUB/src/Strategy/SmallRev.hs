{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}

module Strategy.SmallRev where

import Etna.Lib
import Impl
import Spec
import Test.SmallCheck.Series

instance Monad m => Serial m Typ where
  series = cons2 All \/ cons2 Arr \/ cons1 TVar \/ cons0 Top

instance Monad m => Serial m Term where
  series = cons2 TApp \/ cons2 TAbs \/ cons2 App \/ cons2 Abs \/ cons1 Var

$( mkStrategies
     [|scRun Naive scDefaults|]
     [ 'prop_SinglePreserve,
       'prop_MultiPreserve
     ]
 )