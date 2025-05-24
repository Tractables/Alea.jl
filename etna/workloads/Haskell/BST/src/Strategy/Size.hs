{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TemplateHaskell #-}

module Strategy.Size where

import Etna.Lib
import Impl
import Spec
import Test.QuickCheck hiding (Result)

n :: Int
n = readEnv "BSTSIZE"

instance Arbitrary BST where
  arbitrary = do
    ks <- map Key . take n <$> shuffle [1 .. 2 * n]
    vs <- map Val <$> vectorOf n arbitrary
    return $ foldr (uncurry insert) E (zip ks vs)
    where
      -- Correct implementation.
      insert :: Key -> Val -> Tree Key Val -> Tree Key Val
      insert k v E = T E k v E
      insert k v (T l k' v' r)
        | k < k' = T (insert k v l) k' v' r
        | k > k' = T l k' v' (insert k v r)
        | otherwise = T l k' v r

instance Arbitrary Key where
  arbitrary = Key <$> choose (1, 2 * n)

instance Arbitrary Val where
  arbitrary = Val <$> arbitrary

$( mkStrategies
     [|qcRunArb qcDefaults Correct|]
     [ 'prop_InsertValid,
       'prop_DeleteValid,
       'prop_UnionValid,
       'prop_InsertPost,
       'prop_DeletePost,
       'prop_UnionPost,
       'prop_InsertModel,
       'prop_DeleteModel,
       'prop_UnionModel,
       'prop_InsertInsert,
       'prop_InsertDelete,
       'prop_InsertUnion,
       'prop_DeleteInsert,
       'prop_DeleteDelete,
       'prop_DeleteUnion,
       'prop_UnionDeleteInsert,
       'prop_UnionUnionAssoc
     ]
 )

-- TODO: library expects tuple
test_UnionUnionIdem = qcRunArb qcDefaults Correct prop_UnionUnionIdem