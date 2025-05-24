{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}

module Strategy.LeanRev where

import Etna.Lib
import Impl
import Spec
import Test.LeanCheck

instance Listable Typ where
  tiers = cons2 TFun \/ cons0 TBool

instance Listable Expr where
  tiers = cons2 App \/ cons2 Abs \/ cons1 Bool \/ cons1 Var

$( mkStrategies
     [|lcRun Naive maxCap|]
     [ 'prop_SinglePreserve,
       'prop_MultiPreserve
     ]
 )