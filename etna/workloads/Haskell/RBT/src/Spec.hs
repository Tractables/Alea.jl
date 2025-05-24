module Spec where

import Etna.Lib
import Data.Either
import qualified Data.List as L
import Impl

-- Based on SmallCheck implementation (based on Okasaki 1999),
-- but in the style of How to Specify It.

isRBT :: Ord k => Tree k v -> Bool
isRBT t = isBST t && consistentBlackHeight t && noRedRed t && blackRoot t

isBST :: Ord k => Tree k v -> Bool
isBST E = True
isBST (T _ a x _ b) =
  -- Difference from SC: don't allow repeated keys.
  every (< x) a && every (> x) b && isBST a && isBST b
  where
    every p E = True
    every p (T _ a x _ b) = p x && every p a && every p b

-- "No red node has a red parent."
noRedRed :: Tree k v -> Bool
noRedRed E = True
noRedRed (T B a _ _ b) = noRedRed a && noRedRed b
noRedRed (T R a _ _ b) = blackRoot a && blackRoot b && noRedRed a && noRedRed b
  where
    blackRoot (T R _ _ _ _) = False
    blackRoot _ = True

-- "Every path from the root to an empty node contains the same number of black nodes."
consistentBlackHeight :: Tree k v -> Bool
consistentBlackHeight = fst . go
  where
    go E = (True, 1)
    go (T rb a x _ b) =
      (aBool && bBool && aHeight == bHeight, aHeight + isBlack rb)
      where
        (aBool, aHeight) = go a
        (bBool, bHeight) = go b

        isBlack R = 0
        isBlack B = 1

blackRoot :: Tree k v -> Bool
blackRoot E = True
blackRoot (T B _ _ _ _) = True
blackRoot _ = False

toList :: Tree k v -> [(k, v)]
toList E = []
toList (T _ l k v r) =
  toList l ++ [(k, v)] ++ toList r

find :: Ord k => k -> Tree k v -> Maybe v
find _ E = Nothing
find x (T _ l y vy r)
  | x < y = find x l
  | x > y = find x r
  | otherwise = Just vy

----------

newtype Key = Key Int
  deriving (Eq, Ord, Read, Show)

newtype Val = Val Bool
  deriving (Eq, Ord, Read, Show)

type RBT = Tree Key Val

----------

-- Validity properties.

prop_InsertValid :: Task (RBT, Key, Val)
prop_InsertValid (t, k, v) =
  isRBT t --> fromRight False (isRBT <$> insert k v t)

prop_DeleteValid :: Task (RBT, Key)
prop_DeleteValid (t, k) =
  isRBT t --> fromRight False (isRBT <$> delete k t)

----------

-- Postcondition properties.

prop_InsertPost :: Task (RBT, Key, Key, Val)
prop_InsertPost (t, k, k', v) =
  isRBT t
    --> (find k' <$> insert k v t)
    == return (if k == k' then Just v else find k' t)

prop_DeletePost :: Task (RBT, Key, Key)
prop_DeletePost (t, k, k') =
  isRBT t
    --> (find k' <$> delete k t)
    == return (if k == k' then Nothing else find k' t)

----------

-- Model-based properties.

prop_InsertModel :: Task (RBT, Key, Val)
prop_InsertModel (t, k, v) =
  isRBT t
    --> (toList <$> insert k v t)
    == return (L.insert (k, v) (deleteKey k $ toList t))

prop_DeleteModel :: Task (RBT, Key)
prop_DeleteModel (t, k) =
  isRBT t
    --> (toList <$> delete k t)
    == return (deleteKey k (toList t))

deleteKey :: Ord k => k -> [(k, v)] -> [(k, v)]
deleteKey k = filter ((/= k) . fst)

----------

-- Metamorphic properties.

prop_InsertInsert :: Task (RBT, Key, Key, Val, Val)
prop_InsertInsert (t, k, k', v, v') =
  isRBT t
    --> (insert k v =<< insert k' v' t)
    =~= if k == k' then insert k v t else insert k' v' =<< insert k v t

prop_InsertDelete :: Task (RBT, Key, Key, Val)
prop_InsertDelete (t, k, k', v) =
  isRBT t
    --> (insert k v =<< delete k' t)
    =~= if k == k' then insert k v t else delete k' =<< insert k v t

prop_DeleteInsert :: Task (RBT, Key, Key, Val)
prop_DeleteInsert (t, k, k', v') =
  isRBT t
    --> (delete k =<< insert k' v' t)
    =~= if k == k' then delete k t else insert k' v' =<< delete k t

prop_DeleteDelete :: Task (RBT, Key, Key)
prop_DeleteDelete (t, k, k') =
  isRBT t
    --> (delete k =<< delete k' t)
    =~= (delete k' =<< delete k t)

(=~=) :: Either Error (Tree Key Val) -> Either Error (Tree Key Val) -> Bool
(Right t1) =~= (Right t2) = toList t1 == toList t2
_ =~= _ = False

----------

sizeRBT :: RBT -> Int
sizeRBT = length . toList