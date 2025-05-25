module Impl where

import Data.Maybe (fromMaybe)

-- Standard de Bruijn presentation.

data Typ
  = Top
  | TVar Int
  | Arr Typ Typ
  | All Typ Typ
  deriving (Eq, Ord, Read, Show)

data Term
  = Var Int
  | Abs Typ Term
  | App Term Term
  | TAbs Typ Term
  | TApp Term Typ
  deriving (Eq, Ord, Read, Show)

-- shifting and substitution --

tshift :: Int -> Typ -> Typ
tshift _ Top = Top
tshift x (TVar y)
  {-! -}
  | x <= y = TVar (1 + y)
  | otherwise = TVar y
  {-!! tshift_tvar_all -}
  {-!
  = TVar (1 + y)
  -}
  {-!! tshift_tvar_no_incr -}
  {-!
  = TVar y
  -}
tshift x (Arr ty1 ty2) = Arr (tshift x ty1) (tshift x ty2)
tshift x (All ty1 ty2) =
  {-! -}
  All (tshift x ty1) (tshift (1 + x) ty2)
  {-!! tshift_all_no_incr -}
  {-!
  All (tshift x ty1) (tshift x ty2)
  -}

shift :: Int -> Term -> Term
shift x (Var y) = 
  {-! -} 
  Var (if x <= y then 1 + y else y)
  {-!! shift_var_all -}
  {-!
  Var (1 + y)
  -}
  {-!! shift_var_no_incr -}
  {-!
  Var y
  -}
shift x (Abs ty1 t2) = 
  {-! -} 
  Abs ty1 (shift (1 + x) t2)
  {-!! shift_abs_no_incr -}
  {-!
  Abs ty1 (shift x t2)
  -}
shift x (App t1 t2) = App (shift x t1) (shift x t2)
shift x (TAbs ty1 t2) = TAbs ty1 (shift x t2)
shift x (TApp t1 ty2) = TApp (shift x t1) ty2

shiftTyp :: Int -> Term -> Term
shiftTyp _ t@(Var _) = t
shiftTyp x (Abs ty1 t2) = Abs (tshift x ty1) (shiftTyp x t2)
shiftTyp x (App t1 t2) = App (shiftTyp x t1) (shiftTyp x t2)
shiftTyp x (TAbs ty1 t2) = 
  {-! -}
  TAbs (tshift x ty1) (shiftTyp (1 + x) t2)
  {-!! shift_typ_tabs_no_incr -}
  {-! 
  TAbs (tshift x ty1) (shiftTyp x t2)
  -}
shiftTyp x (TApp t1 ty2) = TApp (shiftTyp x t1) (tshift x ty2)

tsubst :: Typ -> Int -> Typ -> Typ
tsubst Top _ _ = Top 
tsubst (TVar y) x ty'
  {-! -}
  | y < x = TVar y
  | y == x = ty'
  | otherwise = TVar (y - 1)
  {-!! tsubst_tvar_flip -}
  {-!
  | y < x = TVar (y - 1)
  | y == x = ty'
  | otherwise = TVar y
  -}
  {-!! tsubst_tvar_no_shift -}
  {-!
  | y < x = TVar y
  | y == x = ty'
  | otherwise = TVar y
  -}
  {-!! tsubst_tvar_over_shift -}
  {-!
  | y < x = TVar (y - 1)
  | y == x = ty'
  | otherwise = TVar (y - 1)
  -}
tsubst (Arr ty1 ty2) x ty' = Arr (tsubst ty1 x ty') (tsubst ty2 x ty')
tsubst (All ty1 ty2) x ty' = 
  {-! -}
  All (tsubst ty1 x ty') (tsubst ty2 (1 + x) (tshift 0 ty'))
  {-!! tsubst_all_no_tshift -}
  {-! 
  All (tsubst ty1 x ty') (tsubst ty2 (1 + x) ty')
  -}

subst :: Term -> Int -> Term -> Term
subst (Var y) x t'
  {-! -}
  | y < x = Var y
  | y == x = t'
  | otherwise = Var (y - 1)
  {-!! subst_var_flip -}
  {-!
  | y < x = Var (y - 1)
  | y == x = t'
  | otherwise = Var y
  -}
  {-!! subst_var_no_decr -}
  {-!
  | y < x = Var y
  | y == x = t'
  | otherwise = Var y
  -}
subst (Abs ty1 t2) x t' = 
  {-! -}
  Abs ty1 (subst t2 (1 + x) (shift 0 t'))
  {-!! subst_abs_no_shift -}
  {-! 
  Abs ty1 (subst t2 (1 + x) t')
  -}
  {-!! subst_abs_no_incr -}
  {-! 
  Abs ty1 (subst t2 x (shift 0 t'))
  -}  
subst (App t1 t2) x t' = App (subst t1 x t') (subst t2 x t')
subst (TAbs ty1 t2) x t' = 
  {-! -}
  TAbs ty1 (subst t2 x (shiftTyp 0 t'))
  {-!! subst_tabs_no_shift -}
  {-! 
  TAbs ty1 (subst t2 x t')
  -}
subst (TApp t1 ty2) x t' = TApp (subst t1 x t') ty2

substTyp :: Term -> Int -> Typ -> Term
substTyp t@(Var _) _ _ = t
substTyp (Abs ty1 t2) x ty = Abs (tsubst ty1 x ty) (substTyp t2 x ty)
substTyp (App t1 t2) x ty = App (substTyp t1 x ty) (substTyp t2 x ty)
substTyp (TAbs ty1 t2) x ty = 
  {-! -}
  TAbs (tsubst ty1 x ty) (substTyp t2 (1 + x) (tshift 0 ty))
  {-!! subst_typ_tabs_no_incr -}
  {-! 
  TAbs (tsubst ty1 x ty) (substTyp t2 x (tshift 0 ty))
  -}
  {-!! subst_typ_tabs_no_shift -}
  {-! 
  TAbs (tsubst ty1 x ty) (substTyp t2 (1 + x) ty)
  -}
substTyp (TApp t1 ty2) x ty = TApp (substTyp t1 x ty) (tsubst ty2 x ty)

-- stepping --

pstep :: Term -> Maybe Term
pstep (Abs ty t) = Abs ty <$> pstep t
pstep (App (Abs _ t1) t2) =
  let t1' = fromMaybe t1 (pstep t1)
      t2' = fromMaybe t2 (pstep t2)
   in return (subst t1' 0 t2')
pstep (App t1 t2) =
  case (pstep t1, pstep t2) of
    (Nothing, Nothing) -> Nothing
    (mt1, mt2) ->
      let t1' = fromMaybe t1 (pstep t1)
          t2' = fromMaybe t2 (pstep t2)
       in return (App t1' t2')
pstep (TAbs ty t) = TAbs ty <$> pstep t
pstep (TApp (TAbs _ t) ty) =
  let t' = fromMaybe t (pstep t)
   in return (substTyp t' 0 ty)
pstep (TApp t ty) = (`TApp` ty) <$> pstep t
pstep _ = Nothing