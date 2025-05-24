{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}

module Strategy.Quick where

import Etna.Lib
import Data.Maybe
import GHC.Generics
import Generic.Random
import Impl
import Spec
import Test.QuickCheck hiding (Result)

deriving instance Generic Typ

instance Arbitrary Typ where
  arbitrary =
    genericArbitraryRec
      ( 1
          % 1
          % ()
      )
      `withBaseCase` return TBool

deriving instance Generic Expr

instance Arbitrary Expr where
  arbitrary =
    genericArbitraryRec
      ( 1
          % 1
          % 1
          % 1
          % ()
      )
      `withBaseCase` return (Bool True)

$( mkStrategies
     [|qcRunArb qcDefaults Naive|]
     [ 'prop_SinglePreserve,
       'prop_MultiPreserve
     ]
 )