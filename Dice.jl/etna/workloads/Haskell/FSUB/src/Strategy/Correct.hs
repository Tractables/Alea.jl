{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TupleSections #-}

module Strategy.Correct where

import Etna.Lib
import Impl (Term (..), Typ (..))
import Spec
import Test.QuickCheck hiding (Result)
import Util

instance Arbitrary Term where
  arbitrary = do
    let size = 4
    ty <- genExactTyp size Empty
    mt <- genExactTerm size Empty ty
    maybe discard return mt

-- Generator for types --

genExactTyp :: Int -> Env -> Gen Typ
genExactTyp 0 e = genExactTyp0 e
genExactTyp n' e =
  frequency [(2, genAll), (2, genArr), (1, genExactTyp0 e)]
  where
    n = n' - 1

    genAll = do
      ty1 <- oneof [return Top, genExactTyp n e]
      ty2 <- genExactTyp n (EBound e ty1)
      return (All ty1 ty2)

    genArr = do
      ty1 <- oneof $ genExactTyp n e : genExactTVar0' e
      ty2 <- genExactTyp n (EVar e ty1)
      return (Arr ty1 ty2)

genExactTyp0 :: Env -> Gen Typ
genExactTyp0 e =
  let base = return $ All Top (Arr (TVar 0) (TVar 0))
      gs =
        map
          ( \g -> do
              ty <- g
              return (Arr ty ty)
          )
          (genExactTVar0' e)
   in frequency_ base (map (1,) gs)

genExactVar0' :: Env -> [Gen Typ]
genExactVar0' = map return . go
  where
    go :: Env -> [Typ]
    go Empty = []
    go (EBound e _) = map (tshift 0) (go e)
    go (EVar e ty) = ty : go e

genExactTVar0' :: Env -> [Gen Typ]
genExactTVar0' e =
  case countTVar e of
    0 -> []
    n ->
      [ do
          n' <- choose (0, n - 1)
          return (TVar n')
      ]

countTVar :: Env -> Int
countTVar Empty = 0
countTVar (EVar e _) = countTVar e
countTVar (EBound e _) = 1 + countTVar e

-- Generator for terms --

genExactTerm :: Int -> Env -> Typ -> Gen (Maybe Term)
genExactTerm 0 e ty = genExactTerm0 e ty
genExactTerm n' e ty =
  backtrack [(1, g0), (1, g1), (1, g2), (1, g3), (1, g4)]
  where
    n = n' - 1

    g0 = genExactTerm0 e ty

    g1 = case ty of
      Arr ty1 ty2 -> Abs ty1 <$$> genExactTerm n (EVar e ty1) ty2
      All ty1 ty2 -> TAbs ty1 <$$> genExactTerm n (EBound e ty1) ty2
      _ -> return Nothing

    g2 = do
      ty1 <- genExactTyp n e
      t1 <- genExactTerm n e (Arr ty1 ty)
      t2 <- genExactTerm n e ty1
      return (App <$> t1 <*> t2)

    g3 = do
      ty1 <- genExactTyp n e
      t1 <- genExactTerm n e (All ty1 (tshift 0 ty))
      return (TApp <$> t1 <*> Just ty1)

    g4 = do
      tup <- genReplace ty
      case tup of
        Nothing -> return Nothing
        Just (ty2, ty12) -> do
          t1 <- genExactTerm n e (All ty2 ty12)
          return (TApp <$> t1 <*> Just ty2)

genExactTerm0 :: Env -> Typ -> Gen (Maybe Term)
genExactTerm0 e ty = backtrack [(1, g), (1, genBoundVars e ty)]
  where
    g = case ty of
      Arr ty1 ty2 -> Abs ty1 <$$> genExactTerm0 (EVar e ty1) ty2
      All ty1 ty2 -> TAbs ty1 <$$> genExactTerm0 (EBound e ty1) ty2
      _ -> return Nothing

genBoundVars :: Env -> Typ -> Gen (Maybe Term)
genBoundVars e ty =
  oneof_ (return Nothing) $
    map (fmap Just) $
      genBoundVars' e ty

genBoundVars' :: Env -> Typ -> [Gen Term]
genBoundVars' e ty = map return $ go 0 0 e ty
  where
    go _ _ Empty _ = []
    go n m (EBound e _) ty = go n (1 + m) e ty
    go n m (EVar e ty') ty =
      let rest = go (1 + n) m e ty
       in if ty == tlift m ty' then Var n : rest else rest

tlift :: Int -> Typ -> Typ
tlift 0 ty = ty
tlift n ty = tlift (n - 1) (tshift 0 ty)

genReplace :: Typ -> Gen (Maybe (Typ, Typ))
genReplace ty = do
  mty1 <- genCand ty
  case mty1 of
    Nothing -> return Nothing
    Just ty1 -> do
      ty2 <- replaceTyp 0 (tshift 0 ty) (tshift 0 ty1)
      return $ Just (ty1, ty2)

genCand :: Typ -> Gen (Maybe Typ)
genCand =
  elements_ Nothing . map Just . fetchCandidateTyps

fetchCandidateTyps :: Typ -> [Typ]
fetchCandidateTyps = f 0
  where
    f :: Int -> Typ -> [Typ]
    f n ty =
      let l1 = [tunshift n ty | fetchP n ty]
          l2 = case ty of
            Arr ty1 ty2 -> f n ty1 ++ f n ty2
            All ty1 ty2 -> f n ty1 ++ f (n + 1) ty2
            _ -> []
       in l1 ++ l2

    fetchP _ Top = True
    fetchP n (TVar n') = n <= n'
    fetchP n (Arr ty1 ty2) = fetchP n ty1 && fetchP n ty2
    fetchP n (All ty1 ty2) = fetchP n ty1 && fetchP (n + 1) ty2

    tunshift _ Top = Top
    tunshift n (TVar n') = TVar (n' - n)
    tunshift n (Arr ty1 ty2) = Arr (tunshift n ty1) (tunshift n ty2)
    tunshift n (All ty1 ty2) = All (tunshift n ty1) (tunshift (n + 1) ty2)

-- TODO: look at this
replaceTyp :: Int -> Typ -> Typ -> Gen Typ
replaceTyp n ty ty' = frequency_ (return ty) ((n + 2, g2) : g1)
  where
    g1 = if ty == ty' then [(n + 2, return (TVar n))] else [(1, return ty)]

    g2 = case ty of
      Arr ty1 ty2 -> do
        ty1' <- replaceTyp n ty1 ty'
        ty2' <- replaceTyp n ty2 ty'
        return (Arr ty1' ty2')
      All ty1 ty2 -> do
        ty1' <- replaceTyp n ty1 ty'
        ty2' <- replaceTyp (n + 1) ty2 (tshift 0 ty')
        return (All ty1' ty2')
      _ -> frequency_ (return ty) g1

oneof_ :: Gen a -> [Gen a] -> Gen a
oneof_ = withBase id oneof

elements_ :: a -> [a] -> Gen a
elements_ = withBase return elements

frequency_ :: Gen a -> [(Int, Gen a)] -> Gen a
frequency_ ga ias = withBase id frequency ga ias'
  where
    ias' = filter ((> 0) . fst) ias

withBase :: (b -> Gen a) -> ([c] -> Gen a) -> (b -> [c] -> Gen a)
withBase fb _ b [] = fb b
withBase _ fc _ cs = fc cs

(<$$>) :: (Functor f, Functor g) => (a -> b) -> f (g a) -> f (g b)
(<$$>) = fmap . fmap

-- Correct version.
tshift :: Int -> Typ -> Typ
tshift x (TVar y)
  | x <= y = TVar (1 + y)
  | otherwise = TVar y
tshift _ Top = Top
tshift x (Arr ty1 ty2) = Arr (tshift x ty1) (tshift x ty2)
tshift x (All ty1 ty2) =
  All (tshift x ty1) (tshift (1 + x) ty2)

$( mkStrategies
     [|qcRunArb qcDefaults Correct|]
     [ 'prop_SinglePreserve,
       'prop_MultiPreserve
     ]
 )