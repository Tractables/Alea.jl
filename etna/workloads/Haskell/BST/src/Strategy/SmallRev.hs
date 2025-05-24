{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}

module Strategy.SmallRev where

import Etna.Lib
import Impl
import Strategy.SpecRev
import Spec (BST, Key (..), Val (..))
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