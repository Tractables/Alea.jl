From QuickChick Require Import QuickChick. Import QcNotation.
From Coq Require Import Bool ZArith List. Import ListNotations.
From ExtLib Require Import Monad.
From ExtLib.Data.Monads Require Import OptionMonad.
Import MonadNotation.

From STLC Require Import Impl Spec.

Fixpoint genTyp (size : nat) : G (Typ) :=
  match size with
  | O  => 
    (* Frequency1 (single-branch) *) 
    (returnGen (TBool ))
  | S size1 => 
    (* Frequency2 *) (freq [
      (* TBool *) (match (size) with
      | (1) => 50
      | (2) => 50
      | _ => 500
      end,
      (returnGen (TBool ))); 
      (* TFun *) (match (size) with
      | (1) => 50
      | (2) => 50
      | _ => 500
      end,
      (bindGen (genTyp size1) 
      (fun p1 => 
        (bindGen (genTyp size1) 
        (fun p2 => 
          (returnGen (TFun p1 p2)))))))])
  end.

Fixpoint genExpr (size : nat) : G (Expr) :=
  match size with
  | O  => 
    (* Frequency3 *) (freq [
      (* Var *) (match (size) with
      | (0) => 50
      | _ => 500
      end,
      (bindGen 
      arbitrary 
      (fun p1 => 
        (returnGen (Var p1))))); 
      (* Bool *) (match (size) with
      | (0) => 50
      | _ => 500
      end,
      (bindGen 
      arbitrary 
      (fun p1 => 
        (returnGen (Bool p1)))))])
  | S size1 => 
    (* Frequency4 *) (freq [
      (* Var *) (match (size) with
      | (1) => 64
      | (2) => 51
      | (3) => 32
      | (4) => 11
      | (5) => 0
      | _ => 500
      end,
      (bindGen 
      arbitrary 
      (fun p1 => 
        (returnGen (Var p1))))); 
      (* Bool *) (match (size) with
      | (1) => 64
      | (2) => 51
      | (3) => 32
      | (4) => 11
      | (5) => 0
      | _ => 500
      end,
      (bindGen 
      arbitrary 
      (fun p1 => 
        (returnGen (Bool p1))))); 
      (* Abs *) (match (size) with
      | (1) => 31
      | (2) => 56
      | (3) => 65
      | (4) => 71
      | (5) => 82
      | _ => 500
      end,
      (bindGen (genTyp 2) 
      (fun p1 => 
        (bindGen (genExpr size1) 
        (fun p2 => 
          (returnGen (Abs p1 p2))))))); 
      (* App *) (match (size) with
      | (1) => 31
      | (2) => 41
      | (3) => 62
      | (4) => 78
      | (5) => 91
      | _ => 500
      end,
      (bindGen (genExpr size1) 
      (fun p1 => 
        (bindGen (genExpr size1) 
        (fun p2 => 
          (returnGen (App p1 p2)))))))])
  end.

Definition gSized :=
  (genExpr 5).

Definition test_prop_SinglePreserve :=
forAll gSized (fun (e: Expr) =>
  prop_SinglePreserve e).

(*! QuickChick test_prop_SinglePreserve. *)

Definition test_prop_MultiPreserve :=
forAll gSized (fun (e: Expr) =>
  prop_MultiPreserve e).

(*! QuickChick test_prop_MultiPreserve. *)
          
