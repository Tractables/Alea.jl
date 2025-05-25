{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}

module Strategy.Small where

import Etna.Lib
import Impl
import Spec
import Test.SmallCheck.Series

instance Monad m => Serial m Typ where
  series = cons0 Top \/ cons1 TVar \/ cons2 Arr \/ cons2 All

instance Monad m => Serial m Term where
  series = cons1 Var \/ cons2 Abs \/ cons2 App \/ cons2 TAbs \/ cons2 TApp

$( mkStrategies
     [|scRun Naive scDefaults|]
     [ 'prop_SinglePreserve,
       'prop_MultiPreserve
     ]
 )