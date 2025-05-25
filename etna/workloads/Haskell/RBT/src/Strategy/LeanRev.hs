{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}

module Strategy.LeanRev where

import Etna.Lib
import Impl
import Strategy.SpecRev
import Spec (Key (..), RBT, Val (..))
import Test.LeanCheck

deriveListable ''Key

deriveListable ''Val

deriveListable ''Color

deriveListable ''Tree

$( mkStrategies
     [|lcRun Naive maxCap|]
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