{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}

module Strategy.Quick where

import Etna.Lib
import GHC.Generics (Generic)
import Generic.Random
import Impl
import Spec
import Test.QuickCheck hiding (Result)

deriving instance Generic Typ

instance Arbitrary Typ where
  arbitrary =
    genericArbitraryRec (1 % 1 % 1 % 1 % ())
      `withBaseCase` return Top

deriving instance Generic Term

instance Arbitrary Term where
  arbitrary =
    genericArbitraryRec (1 % 1 % 1 % 1 % 1 % ())
      `withBaseCase` return (Var 0)

$( mkStrategies
     [|qcRunArb qcDefaults Naive|]
     [ 'prop_SinglePreserve,
       'prop_MultiPreserve
     ]
 )

-- causes loop on mutant tshift_tvar_no_incr
t :: Term
t = TAbs Top (TAbs (TVar 0) (Abs (TVar 0) (App (Var 0) (Var 0))))