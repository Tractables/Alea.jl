{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}

module Strategy.QuickIndex where

import Etna.Lib
import GHC.Generics (Generic)
import Generic.Random
import Impl
import Spec
import Test.QuickCheck hiding (Result)

deriving instance Generic Typ

instance Arbitrary Typ where
  arbitrary =
    genericArbitraryRecG customInt (1 % 1 % 1 % 1 % ())
      `withBaseCase` return Top
    where
      customInt :: Gen Int
      customInt = oneof [return 0, return 1, return 2]

deriving instance Generic Term

instance Arbitrary Term where
  arbitrary =
    genericArbitraryRecG customInt (1 % 1 % 1 % 1 % 1 % ())
      `withBaseCase` return (Var 0)
    where
      customInt :: Gen Int
      customInt = oneof [return 0, return 1, return 2]

$( mkStrategies
     [|qcRunArb qcDefaults Naive|]
     [ 'prop_SinglePreserve,
       'prop_MultiPreserve
     ]
 )