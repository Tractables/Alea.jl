From QuickChick Require Import QuickChick.

Require Import TestingCommon.
Require Import Reachability.
Require Import SSNI.
Require Import SanityChecks.
Require Import ZArith.
(* Require Import Generation. *)
From mathcomp Require Import ssreflect eqtype seq.
Import LabelEqType.

#[local] Instance FuzzyZ : Fuzzy Z :=
  {| fuzz n := choose (n - 5, n + 5)%Z |}.

Derive (Arbitrary, Fuzzy) for BinOpT.
Derive (Arbitrary, Fuzzy) for Instr.
Derive (Arbitrary, Fuzzy) for Pointer.
Derive (Arbitrary, Fuzzy) for Value.
Derive (Arbitrary, Fuzzy) for Atom.
Derive (Arbitrary, Fuzzy) for Ptr_atom.
Derive (Arbitrary, Fuzzy) for StackFrame.
Derive (Arbitrary, Fuzzy) for Stack.
Derive (Arbitrary, Fuzzy) for SState.
Derive (Arbitrary, Fuzzy) for Variation.


(* 
ManualExtract BinOpT.
ManualExtract Instr.
ManualExtract Pointer.
ManualExtract Value.
ManualExtract Atom.
ManualExtract Ptr_atom.
ManualExtract StackFrame.
ManualExtract Stack.
ManualExtract SState.
ManualExtract Variation. *)
  
Definition test_propSSNI_smart (v: @Variation SState) :=
    propSSNI_smart default_table v.

Axiom num_tests : nat. Extract Constant num_tests => "max_int".

Definition gen_variation_copy : G (@Variation SState) :=
  bindGen arbitrary (fun l  =>
  bindGen arbitrary (fun st => 
  returnGen (Var l st st))).

  
Definition test_propSSNI_smart_fuzzer :=
  fun (u : unit) => fuzzLoopWith (updMaxDiscard (updMaxSuccess (updAnalysis stdArgs true) num_tests) num_tests) gen_variation_copy fuzz show test_propSSNI_smart.

(*! FuzzChick test_propSSNI_smart (test_propSSNI_smart_fuzzer tt). *)

  (* gen_variation_SState
  gen_variation_copy: fuzzy
  gen_variation_naive == arbitrary/random
  gen_variation_naive: fuzzy *)
