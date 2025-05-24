{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}

module Strategy.SmallRev where

import Etna.Lib
import Impl
import Spec
import Test.SmallCheck.Series

instance Monad m => Serial m Typ where
  series = cons2 TFun \/ cons0 TBool

instance Monad m => Serial m Expr where
  series = cons2 App \/ cons2 Abs \/ cons1 Bool \/ cons1 Var

$( mkStrategies
     [|scRun Naive scDefaults|]
     [ 'prop_SinglePreserve,
       'prop_MultiPreserve
     ]
 )