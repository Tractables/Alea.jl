

From QuickChick Require Import QuickChick. Import QcNotation.
From Coq Require Import Bool ZArith List. Import ListNotations.
From ExtLib Require Import Monad.
From ExtLib.Data.Monads Require Import OptionMonad.
Import MonadNotation.


Inductive Typ :=
| TBool : Typ
| TFun  : Typ -> Typ -> Typ
.

#[export] Instance dec_type (t1 t2 : Typ) : Dec (t1 = t2).
Proof. dec_eq. Defined.

Derive (Show, Sized) for Typ.

Inductive Expr :=
| Var   : nat -> Expr
| Bool  : bool -> Expr
| Abs   : Typ -> Expr -> Expr
| App   : Expr -> Expr -> Expr
.

Derive (Show, Sized) for Expr.

Definition Ctx := list Typ.

(* Fixpoint typ_eqb (t1 t2: Typ) : bool :=
    match t1, t2 with
    | TBool, TBool => true
    | TBool, TFun _ _ => false
    | TFun _ _, TBool => false
    | TFun t1' t1'', TFun t2' t2'' => (typ_eqb t1'  t2') && (typ_eqb t1'' t2'')
    end.
  
Notation "A == B" := (typ_eqb A B) (at level 100, right associativity). *)


Fixpoint getTyp (ctx: Ctx) (e: Expr) : option Typ :=
    match e with
    | (Var n) =>
        (* if (0 <=? n) && ((List.length ctx) <? n) then (List.nth_error ctx (n)) *)
        List.nth_error ctx n
        (* else  None *)
    | (Bool _) => 
        Some TBool
    | (Abs t e) =>
        t' <- getTyp (t::ctx) e ;;
        Some (TFun t t')
    | (App e1 e2) => 
        t1' <- getTyp ctx e1 ;;
        match t1' with
        | TFun t11 t12 =>
            t2 <- getTyp ctx e2 ;;
            if (t11 = t2)? then Some t12 else None
        | _ => None
        end
    end
.

Definition typeCheck (ctx: Ctx) (e: Expr) (t: Typ) : bool :=
    match getTyp ctx e with
    | Some t' => (t = t')?
    | None => false
    end
.



Definition shift  (d: Z) (ex: Expr) : Expr :=
    let fix go (c: Z) (e: Expr):=
        match e with 
        | Var n =>
            (*! *)
            if n <? Z.to_nat c then Var n
            else Var (Z.to_nat ((Z.of_nat n) + d))
            (*!! shift_var_none *)
            (*!
            Var n
            *)
            (*!! shift_var_all *)
            (*!             
            Var (Z.to_nat (Z.of_nat n + d))
            *)
            (*!! shift_var_leq *)
            (*!
            if (Z.leb (Z.of_nat n) c) then Var n
            else Var (Z.to_nat (Z.of_nat n + d)) 
            *)
           
        | Bool b => 
            Bool b
        | Abs t e =>
            (*! *)
            Abs t (go (1 + c)%Z e)
            (*!! shift_abs_no_incr *)
            (*!
            Abs t (go c e)
            *)
        | (App e1 e2) => 
            App (go c e1) (go c e2)
        end in
    go 0%Z ex
.



Fixpoint subst  (n: nat) (s: Expr) (e: Expr) : Expr :=
    match n, s, e with 
    | n, s, (Var m) =>
        (*! *)
        if m =? n then s
        else Var m
        (*!! subst_var_all *)
        (*!
        s
        *)
        (*!! subst_var_none *)
        (*!
        Var m
        *)
    | _, _, (Bool b) => Bool b
    | n, s, (Abs t e) =>
        (*! *)
        Abs t (subst (n + 1) (shift 1 s) e)
        (*!! subst_abs_no_shift *)
        (*!
        Abs t (subst (n + 1) s e)
        *)
        (*!! subst_abs_no_incr *)
        (*!
        Abs t (subst n (shift 1 s) e)
        *)
    | n, s, (App e1 e2) => App (subst n s e1) (subst n s e2)
    end.



Definition substTop (s: Expr) (e: Expr) : Expr :=
    (*! *)
    shift (-1) (subst 0 (shift 1 s) e)
    (*!! substTop_no_shift *)
    (*!
    subst 0 s e
    *)
    (*!! substTop_no_shift_back *)
    (*!
    subst 0 (shift 1 s) e
    *)
.

Definition fromMaybe {A} (a: A) (a' : option A) : A :=
    match a' with
    | Some value => value
    | None => a
    end.

Fixpoint pstep  (e: Expr) : option Expr :=
    match e with
    | (Abs t e) => 
        e' <- (pstep e) ;;
        Some (Abs t e')
    | (App (Abs _ e1) e2) =>
        let e1' := fromMaybe e1 (pstep e1) in
        let e2' := fromMaybe e2 (pstep e2) in
            Some (substTop e2' e1')
    | (App e1 e2) =>
        match pstep e1, pstep e2 with
        | None, None => None
        | me1, me2 =>
            let e1' := fromMaybe e1 me1 in
            let e2' := fromMaybe e2 me2 in
                Some (App e1' e2')
        end
    | _ => None
    end.


Fixpoint multistep (f: nat) (step: (Expr -> option Expr))  (e: Expr) : option Expr :=
    match f with
    | O => None
    | S f' =>
        match step e with
        | None => Some e
        | Some e' => multistep f' step e'
        end
    end.


Fixpoint isNF  (e: Expr) : bool :=
    match e with 
    | Var _ => true
    | Bool _ => true
    | Abs _ e => isNF e
    | App (Abs _ _) _ => false
    | App e1 e2 => isNF e1 && isNF e2
    end.