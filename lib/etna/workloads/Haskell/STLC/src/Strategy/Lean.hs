{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}

module Strategy.Lean where

import Etna.Lib
import Impl
import Spec
import Test.LeanCheck

deriveListable ''Typ
deriveListable ''Expr

$( mkStrategies
     [|lcRun Naive maxCap|]
     [ 'prop_SinglePreserve,
       'prop_MultiPreserve
     ]
 )