{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}

module Strategy.Small where

import Etna.Lib
import Data.Functor.Identity
import Impl
import Spec
import Test.SmallCheck.Series

instance Monad m => Serial m BST where
  series = cons0 E \/ cons4 T

instance Monad m => Serial m Key where
  series = Key <$> series

instance Monad m => Serial m Val where
  series = Val <$> series

$( mkStrategies
     [|scRun Naive scDefaults|]
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
       'prop_UnionUnionIdem,
       'prop_UnionUnionAssoc
     ]
 )

-- Number of unique BSTs for singleton, 2-tuple, 3-tuple, 4-tuple with limit of 10000:
-- (16, 10, 6, 3)

-- SC dramatically improves when use <~> instead of <*> in tuple instances.