 
From QuickChick Require Import QuickChick. Import QcNotation.
From Coq Require Import Bool ZArith List. Import ListNotations.
From ExtLib Require Import Monad.
From ExtLib.Data.Monads Require Import OptionMonad.
Import MonadNotation.

From STLC Require Import Impl Spec.

Derive (Arbitrary) for Typ.

Inductive bind : Ctx -> nat -> Typ -> Prop :=
| BindNow   : forall tau env, bind (tau :: env) 0 tau
| BindLater : forall tau tau' x env,
    bind env x tau -> bind (tau' :: env) (S x) tau.

Inductive typing (G : Ctx) : Expr -> Typ -> Prop :=
| TyVar :
    forall x T,
      bind G x T ->
      typing G (Var x) T
| TyBool :
    forall b,
      typing G (Bool b) TBool
| TyAbs :
    forall e T1 T2,
      typing (T1 :: G) e T2 ->
      typing G (Abs T1 e) (TFun T1 T2)
| TyApp :
    forall e1 e2 T1 T2,
      typing G e1 (TFun T1 T2) ->
      typing G e2 T1 ->
      typing G (App e1 e2) T2.


#[export] Instance dec_type (t1 t2 : Typ) : Dec (t1 = t2).
Proof. dec_eq. Defined.
Derive Arbitrary for Typ.

Fixpoint genVar' (ctx: Ctx) (t: Typ) (p: nat) (r: list nat) : list nat :=
  match ctx with
  | nil => r
  | t'::ctx' =>
      if t = t'? then genVar' ctx' t (p + 1) (p :: r)
      else genVar' ctx' t (p + 1) r
  end.

Fixpoint genZero env tau : G (option Expr) :=
  match tau with
  | TBool =>
      bindGen arbitrary
              (fun b : bool =>
                 returnGen (Some (Bool b)))
  | TFun T1 T2 => 
      bindOpt
        (genZero (T1 :: env) T2)
        (fun e : Expr =>
           returnGen (Some (Abs T1 e)))
  end.

  
Fixpoint genExpr env tau (sz: nat) : G (option Expr) :=
  match sz with
  | 0 =>
      backtrack
        [(1, oneOf_ (ret None) (map (fun x => returnGen (Some (Var x))) (genVar' env tau 0 [])))
        ;(1, genZero env tau)] 
  | S sz' =>
      backtrack
        [(1, oneOf_ (ret None) (map (fun x => returnGen (Some (Var x))) (genVar' env tau 0 [])))
         ;
        (1,
          bindGen arbitrary
                  (fun T1 : Typ =>
          bindOpt
            (genExpr env (TFun T1 tau) sz')
            (fun e1 : Expr =>
          bindOpt
            (genExpr env T1 sz')
            (fun e2 : Expr =>
               returnGen (Some (App e1 e2))))))
         ; 
         (1,
           match tau with
           | TBool =>
               bindGen arbitrary
                       (fun b : bool =>
                          returnGen (Some (Bool b)))
           | TFun T1 T2 =>
               bindOpt
                 (genExpr (T1 :: env) T2 sz')
                    (fun e : Expr =>
                     returnGen (Some (Abs T1 e)))
              end)]
  end.

Definition gSized := 
    typ <- arbitrary ;;
    genExpr [] typ 5.


Definition test_prop_SinglePreserve :=
  forAllMaybe gSized (fun (e: Expr) =>
    prop_SinglePreserve e).

(*! QuickChick test_prop_SinglePreserve. *)
  
Definition test_prop_MultiPreserve :=
  forAllMaybe gSized (fun (e: Expr) =>
    prop_MultiPreserve e).
  
(*! QuickChick test_prop_MultiPreserve. *)
