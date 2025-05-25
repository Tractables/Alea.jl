{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use infix" #-}

module Impl where

-- Implementation and bugs from "How to Specify It".

data Tree k v
  = E
  | T (Tree k v) k v (Tree k v)
  deriving (Eq, Ord, Read, Show)

----------

insert :: Ord k => k -> v -> Tree k v -> Tree k v
insert k v E = T E k v E
insert k v (T l k' v' r)
  {-! -}
  | k < k' = T (insert k v l) k' v' r
  | k > k' = T l k' v' (insert k v r)
  | otherwise = T l k' v r
  {-!! insert_1 -}
  {-!
  = T E k v E
  -}
  {-!! insert_2 -}
  {-!
  | k < k' = T (insert k v l) k' v' r
  | otherwise = T l k' v r
  -}
  {-!! insert_3 -}
  {-!
  | k < k' = T (insert k v l) k' v' r
  | k > k' = T l k' v' (insert k v r)
  | otherwise = T l k' v' r
  -}

----------

delete :: Ord k => k -> Tree k v -> Tree k v
delete _ E = E
delete k (T l k' v' r)
  {-! -}
  | k < k' = T (delete k l) k' v' r
  | k > k' = T l k' v' (delete k r)
  | otherwise = join l r
  {-!! delete_4 -}
  {-!
  | k < k' = delete k l
  | k > k' = delete k r
  | otherwise = join l r
  -}
  {-!! delete_5 -}
  {-!
  | k > k' = T (delete k l) k' v' r
  | k < k' = T l k' v' (delete k r)
  | otherwise = join l r
  -}

join :: Tree k v -> Tree k v -> Tree k v
join E r = r
join l E = l
join (T l k v r) (T l' k' v' r') =
  T l k v (T (join r l') k' v' r')

----------

union :: Ord k => Tree k v -> Tree k v -> Tree k v
union E r = r
union l E = l
{-! -}
union (T l k v r) t =
  T (union l (below k t)) k v (union r (above k t))
{-!! union_6 -}
{-!
union (T l k v r) (T l' k' v' r') =
  T l k v (T (union r l') k' v' r')
-}
{-!! union_7 -}
{-!
union (T l k v r) (T l' k' v' r')
  | k == k'   = T (union l l') k v (union r r')
  | k < k'    = T l k v (T (union r l') k' v' r')
  | otherwise = union (T l' k' v' r') (T l k v r)
-}
{-!! union_8 -}
{-!
union (T l k v r) (T l' k' v' r')
  | k == k'   = T (union l l') k v (union r r')
  | k < k'    = T (union l (below k l')) k v
                       (union r (T (above k l') k' v' r'))
  | otherwise = union (T l' k' v' r') (T l k v r)
-}

below :: Ord k => k -> Tree k v -> Tree k v
below _ E = E
below k (T l k' v r)
  | k <= k' = below k l
  | otherwise = T l k' v (below k r)

above :: Ord k => k -> Tree k v -> Tree k v
above _ E = E
above k (T l k' v r)
  | k >= k' = above k r
  | otherwise = T (above k l) k' v r