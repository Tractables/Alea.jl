
From QuickChick Require Import QuickChick. Import QcNotation.
From Coq Require Import Bool ZArith List. Import ListNotations.
From ExtLib Require Import Monad.
From ExtLib.Data.Monads Require Import OptionMonad.
Import MonadNotation.

From STLC Require Import Impl.

Definition mt (e: Expr) : option Typ := 
    getTyp nil e
.

Definition isJust {A} (a: option A) : bool :=
    match a with
    | Some _ => true
    | None => false
    end
.


Definition mtypeCheck (e: option Expr) (t: Typ) : bool :=
    match e with
    | Some e' => typeCheck nil e' t
    | None => true
    end.



Definition prop_SinglePreserve (e: Expr) : option bool :=
  isJust (mt e) -=> 
    t' <- (mt e) ;;
    Some (mtypeCheck (pstep e) t')
.


Definition prop_MultiPreserve (e: Expr) : option bool :=
  isJust (mt e) -=> 
    t' <- mt e ;;
    Some (mtypeCheck (multistep 40 pstep e) t')
.




Fixpoint sizeSTLC (e: Expr) : nat :=
    match e with
    | (Abs _ e) => 1 + sizeSTLC e
    | (App e1 e2) => 1 + sizeSTLC e1 + sizeSTLC e2
    | _ => 1
    end
.
