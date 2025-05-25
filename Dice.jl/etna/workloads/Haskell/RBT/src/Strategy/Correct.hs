{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TemplateHaskell #-}

module Strategy.Correct where

import Etna.Lib
import Impl
import Spec
import Test.QuickCheck hiding (Result)

instance Arbitrary RBT where
  arbitrary = do
    kvs <- arbitrary :: Gen [(Key, Val)]
    return $ foldr (uncurry insert) E kvs
    where
      -- Correct implementation.
      insert :: Ord k => k -> v -> Tree k v -> Tree k v
      insert k vk s = blacken (ins k vk s)
        where
          ins x vx E = T R E x vx E
          ins x vx (T rb a y vy b)
            | x < y = balance rb (ins x vx a) y vy b
            | x > y = balance rb a y vy (ins x vx b)
            | otherwise = T rb a y vx b

      blacken :: Tree k v -> Tree k v
      blacken E = E
      blacken (T _ a k v b) = T B a k v b

      balance :: Color -> Tree k v -> k -> v -> Tree k v -> Tree k v
      balance B (T R (T R a x vx b) y vy c) z vz d = T R (T B a x vx b) y vy (T B c z vz d)
      balance B (T R a x vx (T R b y vy c)) z vz d = T R (T B a x vx b) y vy (T B c z vz d)
      balance B a x vx (T R (T R b y vy c) z vz d) = T R (T B a x vx b) y vy (T B c z vz d)
      balance B a x vx (T R b y vy (T R c z vz d)) = T R (T B a x vx b) y vy (T B c z vz d)
      balance rb a x vx b = T rb a x vx b

instance Arbitrary Key where
  arbitrary = Key <$> arbitrary

instance Arbitrary Val where
  arbitrary = Val <$> arbitrary

$( mkStrategies
     [|qcRunArb qcDefaults Correct|]
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