{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}

module Strategy.Small where

import Etna.Lib
import Impl
import Spec
import Test.SmallCheck.Series

instance Monad m => Serial m Typ where
  series = cons0 TBool \/ cons2 TFun

instance Monad m => Serial m Expr where
  series = cons1 Var \/ cons1 Bool \/ cons2 Abs \/ cons2 App

$( mkStrategies
     [|scRun Naive scDefaults|]
     [ 'prop_SinglePreserve,
       'prop_MultiPreserve
     ]
 )