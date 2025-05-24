module Strategy.SpecRev where

import Spec (Key (..), RBT, Val (..))
import qualified Spec as S

prop_InsertValid (k, v, t) = S.prop_InsertValid (t, k, v)

prop_DeleteValid (k, t) = S.prop_DeleteValid (t, k)

prop_InsertPost (k, k', v, t) = S.prop_InsertPost (t, k, k', v)

prop_DeletePost (k, k', t) = S.prop_DeletePost (t, k, k')

prop_InsertModel (k, v, t) = S.prop_InsertModel (t, k, v)

prop_DeleteModel (k, t) = S.prop_DeleteModel (t, k)

prop_InsertInsert (k, k', v, v', t) = S.prop_InsertInsert (t, k, k', v, v')

prop_InsertDelete (k, k', v, t) = S.prop_InsertDelete (t, k, k', v)

prop_DeleteInsert (k, k', v', t) = S.prop_DeleteInsert (t, k, k', v')

prop_DeleteDelete (k, k', t) = S.prop_DeleteDelete (t, k, k')