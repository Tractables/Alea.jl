module Strategy.SpecRev where

import Spec (BST, Key (..), Val (..))
import qualified Spec as S

prop_InsertValid (k, v, t) = S.prop_InsertValid (t, k, v)

prop_DeleteValid (k, t) = S.prop_DeleteValid (t, k)

prop_UnionValid = S.prop_UnionValid

prop_InsertPost (k, k', v, t) = S.prop_InsertPost (t, k, k', v)

prop_DeletePost (k, k', t) = S.prop_DeletePost (t, k, k')

prop_UnionPost (k, k', t) = S.prop_UnionPost (t, k, k')

prop_InsertModel (k, v, t) = S.prop_InsertModel (t, k, v)

prop_DeleteModel (k, t) = S.prop_DeleteModel (t, k)

prop_UnionModel = S.prop_UnionModel

prop_InsertInsert (k, k', v, v', t) = S.prop_InsertInsert (t, k, k', v, v')

prop_InsertDelete (k, k', v, t) = S.prop_InsertDelete (t, k, k', v)

prop_InsertUnion (k, v, t, t') = S.prop_InsertUnion (t, t', k, v)

prop_DeleteInsert (k, k', v', t) = S.prop_DeleteInsert (t, k, k', v')

prop_DeleteDelete (k, k', t) = S.prop_DeleteDelete (t, k, k')

prop_DeleteUnion (k, t, t') = S.prop_DeleteUnion (t, t', k)

prop_UnionDeleteInsert (k, v, t, t') = S.prop_UnionDeleteInsert (t, t', k, v)

prop_UnionUnionIdem = S.prop_UnionUnionIdem

prop_UnionUnionAssoc = S.prop_UnionUnionAssoc