{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}

module Strategy.Quick where

import Etna.Lib
import GHC.Generics
import Generic.Random
import Impl
import Spec
import Test.QuickCheck as QC hiding (Result)

deriving instance Generic RBT

instance Arbitrary RBT where
  arbitrary = genericArbitraryRec (1 % 1 % ()) `withBaseCase` return E

instance Arbitrary Key where
  arbitrary = Key <$> arbitrary

instance Arbitrary Val where
  arbitrary = Val <$> arbitrary

instance Arbitrary Color where
  arbitrary = oneof [return R, return B]

$( mkStrategies
     [|qcRunArb qcDefaults Naive|]
     [ 'prop_InsertValid,
       'prop_DeleteValid,
       'prop_InsertPost,
       'prop_DeletePost,
       'prop_InsertModel,
       'prop_DeleteModel,
       'prop_InsertInsert,
       'prop_InsertDelete,
       'prop_DeleteInsert,
       'prop_DeleteDelete
     ]
 )