module Impl where

import Data.Maybe (fromMaybe)
import GHC.Generics (Generic)

data Typ
  = TBool
  | TFun Typ Typ
  deriving (Eq, Ord, Read, Show)

data Expr
  = Var Int
  | Bool Bool
  | Abs Typ Expr
  | App Expr Expr
  deriving (Eq, Ord, Read, Show)

type Ctx = [Typ]

typeCheck :: Ctx -> Expr -> Typ -> Bool
typeCheck ctx e t =
  case getTyp ctx e of
    Just t' -> t == t'
    Nothing -> False

getTyp :: Ctx -> Expr -> Maybe Typ
getTyp ctx (Var n)
  | n >= 0 && n < length ctx = return (ctx !! n)
  | otherwise = Nothing
getTyp _ (Bool _) = return TBool
getTyp ctx (Abs t e) = do
  t' <- getTyp (t : ctx) e
  return (TFun t t')
getTyp ctx (App e1 e2) = do
  TFun t11 t12 <- getTyp ctx e1
  t2 <- getTyp ctx e2
  if t11 == t2 then return t12 else Nothing

shift :: Int -> Expr -> Expr
shift d = go 0
  where
    go c (Var n)
      {-! -}
      | n < c = Var n
      | otherwise = Var (n + d)
      {-!! shift_var_none -}
      {-!
      = Var n
      -}
      {-!! shift_var_all -}
      {-!
      = Var (n + d)
      -}
      {-!! shift_var_leq -}
      {-!
      | n <= c = Var n
      | otherwise = Var (n + d)
      -}
    go _ (Bool b) = Bool b
    go c (Abs t e) =
      {-! -}
      Abs t (go (c + 1) e)
      {-!! shift_abs_no_incr -}
      {-!
      Abs t (go c e)
      -}
    go c (App e1 e2) = App (go c e1) (go c e2)

-- [n -> s]e
subst :: Int -> Expr -> Expr -> Expr
subst n s (Var m)
  {-! -}
  | m == n = s
  | otherwise = Var m
  {-!! subst_var_all -}
  {-!
  = s
  -}
  {-!! subst_var_none -}
  {-!
  = Var m
  -}
subst _ _ (Bool b) = Bool b
subst n s (Abs t e) =
  {-! -}
  Abs t (subst (n + 1) (shift 1 s) e)
  {-!! subst_abs_no_shift -}
  {-!
  Abs t (subst (n + 1) s e)
  -}
  {-!! subst_abs_no_incr -}
  {-!
  Abs t (subst n (shift 1 s) e)
  -}
subst n s (App e1 e2) = App (subst n s e1) (subst n s e2)

-- [0 -> s]e
substTop :: Expr -> Expr -> Expr
substTop s e =
  {-! -}
  shift (-1) (subst 0 (shift 1 s) e)
  {-!! substTop_no_shift -}
  {-!
  subst 0 s e
  -}
  {-!! substTop_no_shift_back -}
  {-!
  subst 0 (shift 1 s) e
  -}

pstep :: Expr -> Maybe Expr
pstep (Abs t e) = Abs t <$> pstep e
pstep (App (Abs _ e1) e2) =
  let e1' = fromMaybe e1 (pstep e1)
      e2' = fromMaybe e2 (pstep e2)
   in return (substTop e2' e1')
pstep (App e1 e2) =
  case (pstep e1, pstep e2) of
    (Nothing, Nothing) -> Nothing
    (me1, me2) ->
      let e1' = fromMaybe e1 me1
          e2' = fromMaybe e2 me2
       in return (App e1' e2')
pstep _ = Nothing

multistep :: Int -> (Expr -> Maybe Expr) -> Expr -> Maybe Expr
multistep 0 _ _ = Nothing
multistep fuel step e =
  case step e of
    Nothing -> return e
    Just e' -> multistep (fuel - 1) step e'

isNF :: Expr -> Bool
isNF (Var _) = True
isNF (Bool _) = True
isNF (Abs _ e) = isNF e
isNF (App (Abs _ _) _) = False
isNF (App e1 e2) = isNF e1 && isNF e2