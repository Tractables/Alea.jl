module Util where

import Data.Maybe (isJust)
import Impl

-- contexts --

data Env
  = Empty
  | EVar Env Typ -- type of var
  | EBound Env Typ -- type of tvar
  deriving (Eq, Show)

getBound :: Env -> Int -> Maybe Typ
getBound Empty x = Nothing
getBound (EVar e' ty) x = getBound e' x
getBound (EBound e' ty) x =
  tshift 0 <$> case x of
    0 -> Just ty
    _ -> getBound e' (x - 1)

getVar :: Env -> Int -> Maybe Typ
getVar Empty x = Nothing
getVar (EBound e' _) x = tshift 0 <$> getVar e' x
getVar (EVar e' ty) 0 = Just ty
getVar (EVar e' ty) x = getVar e' (x - 1)

-- well-formedness --

-- Variables must all be bound.

wfTyp :: Env -> Typ -> Bool
wfTyp _ Top = True
wfTyp e (TVar x) = isJust $ getBound e x
wfTyp e (Arr ty1 ty2) = wfTyp e ty1 && wfTyp e ty2
wfTyp e (All ty1 ty2) = wfTyp e ty1 && wfTyp (EBound e ty1) ty2

wfTerm :: Env -> Term -> Bool
wfTerm e (Var x) = isJust $ getVar e x
wfTerm e (Abs ty1 t2) = wfTyp e ty1 && wfTerm (EVar e ty1) t2
wfTerm e (App t1 t2) = wfTerm e t1 && wfTerm e t2
wfTerm e (TAbs ty1 t2) = wfTyp e ty1 && wfTerm (EBound e ty1) t2
wfTerm e (TApp t1 ty2) = wfTerm e t1 && wfTyp e ty2

wfEnv :: Env -> Bool
wfEnv Empty = True
wfEnv (EVar e ty) = wfTyp e ty && wfEnv e
wfEnv (EBound e ty) = wfTyp e ty && wfEnv e

-- reduction --

data Ctx
  = Hole
  | AppFun Ctx Term
  | AppArg Ctx Term -- needs to be a value
  | TypeFun Ctx Typ
  deriving (Eq, Show)

ctxApp :: Ctx -> Term -> Term
ctxApp Hole t = t
ctxApp (AppFun c' t') t = App (ctxApp c' t) t'
ctxApp (AppArg c' t') t = App t' (ctxApp c' t)
ctxApp (TypeFun c' ty) t = TApp (ctxApp c' t) ty

-- more stepping --

multistep :: Int -> (Term -> Maybe Term) -> Term -> Maybe Term
multistep 0 _ _ = Nothing
multistep fuel step e =
  case step e of
    Nothing -> return e
    Just e' -> multistep (fuel - 1) step e'

isNF :: Term -> Bool
isNF (Var _) = True
isNF (Abs _ t) = isNF t
isNF (App (Abs _ _) _) = False
isNF (App t1 t2) = isNF t1 && isNF t2
isNF (TAbs _ t) = isNF t
isNF (TApp (TAbs _ _) _) = False
isNF (TApp t _) = isNF t