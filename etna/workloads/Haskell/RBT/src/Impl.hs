module Impl where

-- Based on SmallCheck implementation (based on Okasaki 1999),
-- but in the style of How to Specify It.

data Color = R | B
  deriving (Eq, Ord, Read, Show)

data Tree k v
  = E
  | T Color (Tree k v) k v (Tree k v)
  deriving (Eq, Ord, Read, Show)

insert :: Ord k => k -> v -> Tree k v -> Either Error (Tree k v)
insert x vx s = return $ blacken (ins x vx s)
  where
    ins x vx E = 
      {-! -}
      T R E x vx E
      {-!! miscolor_insert -}
      {-! 
      T B E x vx E 
      -}
    ins x vx (T rb a y vy b)
      {-! -}
      | x < y = balance rb (ins x vx a) y vy b
      | x > y = balance rb a y vy (ins x vx b)
      | otherwise = T rb a y vx b
      {-!! insert_1 -}
      {-!
      = T R E x vx E
      -}
      {-!! insert_2 -}
      {-!
      | x < y = balance rb (ins x vx a) y vy b
      | otherwise = T rb a y vx b
      -}
      {-!! insert_3 -}
      {-!
      | x < y = balance rb (ins x vx a) y vy b
      | x > y = balance rb a y vy (ins x vx b)
      | otherwise = T rb a y vy b
      -}
      {-!! no_balance_insert_1 -}
      {-!
      | x < y = T rb (ins x vx a) y vy b
      | x > y = balance rb a y vy (ins x vx b)
      | otherwise = T rb a y vx b
      -}
      {-!! no_balance_insert_2 -}
      {-!
      | x < y = balance rb (ins x vx a) y vy b
      | x > y = T rb a y vy (insert x vx b)
      | otherwise = T rb a y vx b
      -}

----------

-- Based on https://www.cs.kent.ac.uk/people/staff/smk/redblack/Untyped.hs

data Error = IE -- invariant error
  deriving (Eq, Ord, Show)

delete :: Ord k => k -> Tree k v -> Either Error (Tree k v)
delete x t = 
  {-! -}
  blacken <$> del t
  {-!! miscolor_delete -}
  {-! 
  del t 
  -}
  where
    del E = return E
    del (T _ a y vy b)
      {-! -}
      | x < y = delLeft a y vy b
      | x > y = delRight a y vy b
      | otherwise = join a b
      {-!! delete_4 -}
      {-!
      | x < y = del a
      | x > y = del b
      | otherwise = join a b
      -}
      {-!! delete_5 -}
      {-!
      | x > y = delLeft a y vy b
      | x < y = delRight a y vy b
      | otherwise = join a b
      -}

    delLeft a@(T B _ _ _ _) y vy b = do
      a' <- del a
      balLeft a' y vy b
    delLeft a y vy b = do
      a' <- del a
      return $ T R a' y vy b

    delRight a y vy b@(T B _ _ _ _) = balRight a y vy =<< del b
    delRight a y vy b = T R a y vy <$> del b

balLeft :: Tree k v -> k -> v -> Tree k v -> Either Error (Tree k v)
balLeft (T R a x vx b) y vy c = return $ T R (T B a x vx b) y vy c
balLeft bl x vx (T B a y vy b) = return $ balance B bl x vx (T R a y vy b)
balLeft bl x vx (T R (T B a y vy b) z vz c) =
  {-! -}
  do
  c' <- redden c
  return $ T R (T B bl x vx a) y vy (balance B b z vz c')
  {-!! miscolor_balLeft -}
  {-! 
  return $ T R (T B bl x vx a) y vy (balance B b z vz c)
  -}
balLeft _ _ _ _ = Left IE

balRight :: Tree k v -> k -> v -> Tree k v -> Either Error (Tree k v)
balRight a x vx (T R b y vy c) = return $ T R a x vx (T B b y vy c)
balRight (T B a x vx b) y vy bl = return $ balance B (T R a x vx b) y vy bl
balRight (T R a x vx (T B b y vy c)) z vz bl =
  {-! -}
  do
  a' <- redden a
  return $ T R (balance B a' x vx b) y vy (T B c z vz bl)
  {-!! miscolor_balRight -}
  {-! 
  return $ T R (balance B a x vx b) y vy (T B c z vz bl)
  -}
balRight _ _ _ _ = Left IE

join :: Tree k v -> Tree k v -> Either Error (Tree k v)
join E a = return a
join a E = return a
join (T R a x vx b) (T R c y vy d) = do
  t' <- join b c
  case t' of
    T R b' z vz c' -> 
      {-! -}
      return $ T R (T R a x vx b') z vz (T R c' y vy d)
      {-!! miscolor_join_1 -}
      {-! 
      return $ T R (T B a x vx b') z vz (T B c' y vy d)
      -}
    bc -> return $ T R a x vx (T R bc y vy d)
join (T B a x vx b) (T B c y vy d) = do
  t' <- join b c
  case t' of
    T R b' z vz c' -> 
      {-! -}
      return $ T R (T B a x vx b') z vz (T B c' y vy d)
      {-!! miscolor_join_2 -}
      {-! 
      return $ T R (T R a x vx b') z vz (T R c' y vy d)
      -}
    bc -> balLeft a x vx (T B bc y vy d)
join a (T R b x vx c) = do
  t' <- join a b
  return $ T R t' x vx c
join (T R a x vx b) c = T R a x vx <$> join b c

----------

-- Used for insert and delete.

blacken :: Tree k v -> Tree k v
blacken E = E
blacken (T _ a x vx b) = T B a x vx b

redden :: Tree k v -> Either Error (Tree k v)
redden (T B a x vx b) = return $ T R a x vx b
redden _ = Left IE

balance :: Color -> Tree k v -> k -> v -> Tree k v -> Tree k v
{-! -}
balance B (T R (T R a x vx b) y vy c) z vz d = T R (T B a x vx b) y vy (T B c z vz d)
{-!! swap_cd -}
{-! 
balance B (T R (T R a x vx b) y vy c) z vz d = T R (T B a x vx b) y vy (T B d z vz c) 
-}
balance B (T R a x vx (T R b y vy c)) z vz d = T R (T B a x vx b) y vy (T B c z vz d)
{-! -}
balance B a x vx (T R (T R b y vy c) z vz d) = T R (T B a x vx b) y vy (T B c z vz d)
{-!! swap_bc -}
{-! 
balance B a x vx (T R (T R b y vy c) z vz d) = T R (T B a x vx c) y vy (T B b z vz d) 
-}
balance B a x vx (T R b y vy (T R c z vz d)) = T R (T B a x vx b) y vy (T B c z vz d)
balance rb a x vx b = T rb a x vx b