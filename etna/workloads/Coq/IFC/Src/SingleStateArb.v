
From QuickChick Require Import QuickChick.

Require Import Machine.

Require Import ZArith.
Require Import List.

Require Import TestingCommon.
Require Import Indist.
Require Import BespokeGenerator.
Require Import Shrinking.

Require Import Printing.

(* Leverage the pair/V functions and making everything observable,
   create (inefficient) instances for a single machine *)

(* Generates an SSNI-oriented single machine SState *)
Definition genSState : G SState :=
  bindGen gen_variation_SState (fun v =>
  let '(Var _ st _) := v in
  returnGen st).

Instance gSState : Gen SState :=
{|
  arbitrary := @genSState 
|}.

Instance shrSState : Shrink SState :=
{| shrink x :=
    let all : list (@Variation SState):= shrinkVSState (Var top x x) in
    let SState_of_var v := let '(Var _ x _) := v in x in
    filter (indist top x) (List.map SState_of_var all)
|}.

Instance showSState : Show SState :=
{|
  show x := show_pair top x x
|}.
