module Spec where

import Etna.Lib
import Control.Applicative
import Data.Function
import qualified Data.List as L
import Impl

-- Properties from "How to Specify It".

isBST :: Ord k => Tree k v -> Bool
isBST E = True
isBST (T l k _ r) =
  isBST l
    && isBST r
    && all (< k) (keys l)
    && all (> k) (keys r)

keys :: Tree k v -> [k]
keys = map fst . toList

toList :: Tree k v -> [(k, v)]
toList E = []
toList (T l k v r) =
  toList l ++ [(k, v)] ++ toList r

find :: Ord k => k -> Tree k v -> Maybe v
find _ E = Nothing
find k (T l k' v' r)
  | k < k' = find k l
  | k > k' = find k r
  | otherwise = Just v'

----------

newtype Key = Key Int
  deriving (Eq, Ord, Read, Show)

newtype Val = Val Bool
  deriving (Eq, Ord, Read, Show)

type BST = Tree Key Val

----------

-- Validity properties.

prop_InsertValid :: Task (BST, Key, Val)
prop_InsertValid (t, k, v) =
  isBST t --> isBST (insert k v t)

prop_DeleteValid :: Task (BST, Key)
prop_DeleteValid (t, k) =
  isBST t --> isBST (delete k t)

prop_UnionValid :: Task (BST, BST)
prop_UnionValid (t1, t2) =
  isBST t1 && isBST t2 --> isBST (t1 `union` t2)

----------

-- Postcondition properties.

prop_InsertPost :: Task (BST, Key, Key, Val)
prop_InsertPost (t, k, k', v) =
  isBST t
    --> find k' (insert k v t)
    == if k == k' then Just v else find k' t

prop_DeletePost :: Task (BST, Key, Key)
prop_DeletePost (t, k, k') =
  isBST t
    --> find k' (delete k t)
    == if k == k' then Nothing else find k' t

prop_UnionPost :: Task (BST, BST, Key)
prop_UnionPost (t, t', k) =
  isBST t
    --> find k (t `union` t')
    == (find k t <|> find k t')

----------

-- Model-based properties.

prop_InsertModel :: Task (BST, Key, Val)
prop_InsertModel (t, k, v) =
  isBST t
    --> toList (insert k v t)
    == L.insert (k, v) (deleteKey k $ toList t)

prop_DeleteModel :: Task (BST, Key)
prop_DeleteModel (t, k) =
  isBST t
    --> toList (delete k t)
    == deleteKey k (toList t)

prop_UnionModel :: Task (BST, BST)
prop_UnionModel (t, t') =
  isBST t
    && isBST t'
    --> toList (t `union` t')
    == L.sort (L.unionBy ((==) `on` fst) (toList t) (toList t'))

deleteKey :: Ord k => k -> [(k, v)] -> [(k, v)]
deleteKey k = filter ((/= k) . fst)

----------

-- Metamorphic properties.

prop_InsertInsert :: Task (BST, Key, Key, Val, Val)
prop_InsertInsert (t, k, k', v, v') =
  isBST t
    --> insert k v (insert k' v' t)
    =~= if k == k' then insert k v t else insert k' v' (insert k v t)

prop_InsertDelete :: Task (BST, Key, Key, Val)
prop_InsertDelete (t, k, k', v) =
  isBST t
    --> insert k v (delete k' t)
    =~= if k == k' then insert k v t else delete k' (insert k v t)

prop_InsertUnion :: Task (BST, BST, Key, Val)
prop_InsertUnion (t, t', k, v) =
  isBST t
    && isBST t'
    --> insert k v (t `union` t')
    =~= union (insert k v t) t'

prop_DeleteInsert :: Task (BST, Key, Key, Val)
prop_DeleteInsert (t, k, k', v') =
  isBST t
    --> delete k (insert k' v' t)
    =~= if k == k' then delete k t else insert k' v' (delete k t)

prop_DeleteDelete :: Task (BST, Key, Key)
prop_DeleteDelete (t, k, k') =
  isBST t
    --> delete k (delete k' t)
    =~= delete k' (delete k t)

prop_DeleteUnion :: Task (BST, BST, Key)
prop_DeleteUnion (t, t', k) =
  isBST t
    && isBST t'
    --> delete k (t `union` t')
    =~= union (delete k t) (delete k t')

prop_UnionDeleteInsert :: Task (BST, BST, Key, Val)
prop_UnionDeleteInsert (t, t', k, v) =
  isBST t
    && isBST t'
    --> union (delete k t) (insert k v t')
    =~= insert k v (t `union` t')

prop_UnionUnionIdem :: Task BST
prop_UnionUnionIdem t =
  isBST t
    --> union t t
    =~= t

prop_UnionUnionAssoc :: Task (BST, BST, BST)
prop_UnionUnionAssoc (t1, t2, t3) =
  isBST t1
    && isBST t2
    && isBST t3
    --> union (t1 `union` t2) t3
    == union t1 (t2 `union` t3)

(=~=) :: Tree Key Val -> Tree Key Val -> Bool
t1 =~= t2 = toList t1 == toList t2

----------

sizeBST :: BST -> Int
sizeBST = length . toList
