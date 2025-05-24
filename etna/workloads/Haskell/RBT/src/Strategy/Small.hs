{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}

module Strategy.Small where

import Etna.Lib
import Impl
import Spec
import Test.SmallCheck.Series

instance Monad m => Serial m RBT where
  series = cons0 E \/ cons5 T

instance Monad m => Serial m Key where
  series = Key <$> series

instance Monad m => Serial m Val where
  series = Val <$> series

instance Monad m => Serial m Color where
  series = cons0 R \/ cons0 B

$( mkStrategies
     [|scRun Naive scDefaults|]
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