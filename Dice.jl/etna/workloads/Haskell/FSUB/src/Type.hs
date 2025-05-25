module Type where

import Impl
import Util

typeCheck :: Env -> Term -> Typ -> Bool
typeCheck e t ty =
  case getTyp (-1) e t of -- run indefinitely by default
    Just ty' -> subCheck (-1) e ty' ty
    Nothing -> False

getTyp :: Int -> Env -> Term -> Maybe Typ
getTyp _ e (Var x)
  | wfEnv e = getVar e x
  | otherwise = Nothing
getTyp fuel e (Abs ty1 t2) = do
  ty2 <- getTyp fuel (EVar e ty1) t2 -- or do it here
  return (Arr ty1 ty2)
getTyp fuel e (App t1 t2) = do
  ty1 <- getTyp fuel e t1
  (Arr ty11 ty12) <- promoteTVar fuel e ty1
  ty2 <- getTyp fuel e t2
  if subCheck fuel e ty2 ty11
    then return ty12
    else Nothing
getTyp fuel e (TAbs ty1 t2) = do
  ty2 <- getTyp fuel (EBound e ty1) t2
  return (All ty1 ty2)
getTyp fuel e (TApp t1 ty2) = do
  ty1 <- getTyp fuel e t1
  (All ty11 ty12) <- promoteTVar fuel e ty1
  if subCheck fuel e ty2 ty11
    then return (tsubst ty12 0 ty2)
    else Nothing

promoteTVar :: Int -> Env -> Typ -> Maybe Typ
promoteTVar 0 _ _ = Nothing
promoteTVar _ e ty
  | not (wfEnv e && wfTyp e ty) = Nothing
promoteTVar fuel e (TVar n) = do
  ty <- getBound e n
  promoteTVar (fuel - 1) e ty
promoteTVar _ _ ty = return ty

subCheck :: Int -> Env -> Typ -> Typ -> Bool
subCheck 0 _ _ _ = False
subCheck _ e ty1 Top = wfEnv e && wfTyp e ty1
subCheck fuel e ty1@(TVar x1) ty2
  | ty1 == ty2 = wfEnv e && wfTyp e ty1
  | otherwise =
      case getBound e x1 of
        Just ty1' -> subCheck (fuel - 1) e ty1' ty2
        Nothing -> False
subCheck fuel e (Arr s1 s2) (Arr t1 t2) =
  subCheck (fuel - 1) e t1 s1 && subCheck (fuel - 1) e s2 t2
subCheck fuel e (All s1 s2) (All t1 t2) =
  subCheck (fuel - 1) e t1 s1 && subCheck (fuel - 1) (EBound e t1) s2 t2
subCheck _ _ _ _ = False