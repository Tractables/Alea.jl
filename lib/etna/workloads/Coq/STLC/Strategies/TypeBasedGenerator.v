 
From QuickChick Require Import QuickChick. Import QcNotation.
From Coq Require Import Bool ZArith List. Import ListNotations.
From ExtLib Require Import Monad.
From ExtLib.Data.Monads Require Import OptionMonad.
Import MonadNotation.

From STLC Require Import Impl Spec.

Derive (Arbitrary) for Typ.
Derive (Arbitrary) for Expr.

Definition gSized : G Expr := arbitrary.

Definition test_prop_SinglePreserve :=
  forAll arbitrary (fun (e: Expr) =>
    prop_SinglePreserve e).


(*! QuickChick test_prop_SinglePreserve. *)

Definition test_prop_MultiPreserve :=
  forAll arbitrary (fun (e: Expr) =>
    prop_MultiPreserve e).

(*! QuickChick test_prop_MultiPreserve. *)