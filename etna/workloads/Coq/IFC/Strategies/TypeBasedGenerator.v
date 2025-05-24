From QuickChick Require Import QuickChick.

Require Import TestingCommon.
Require Import Reachability.
Require Import SSNI.
Require Import SanityChecks.
Require Import ZArith.
(* Require Import Generation. *)
From mathcomp Require Import ssreflect eqtype seq.
Import LabelEqType.


Derive Arbitrary for BinOpT.
Derive Arbitrary for Instr.
Derive Arbitrary for Pointer.
Derive Arbitrary for Value.
Derive Arbitrary for Atom.
Derive Arbitrary for Ptr_atom.
Derive Arbitrary for StackFrame.
Derive Arbitrary for Stack.
Derive Arbitrary for SState.
Derive Arbitrary for Variation.

Definition test_propSSNI_smart :=
  forAll arbitrary (fun v =>
    propSSNI_smart default_table v
  ).

(*! QuickChick test_propSSNI_smart.  *)