Require Import ZArith.
Require Import Coq.Strings.String.
Require Import NPeano.

From QuickChick Require Import QuickChick.

Require Export Utils.
Require Export Labels.
Require Export Instructions.
Require Export Memory.
Require Export Indist.
Require Export Machine.

Definition pure {A : Type} (x : A) : G A := returnGen x.

(*
Fixpoint foldGen {A B : Type} (f : A -> B -> G A) (l : list B) (a : A)
: G A :=
  match l with
    | [] => returnGen a
    | (x :: xs) => bindGen (f a x) (foldGen f xs)
  end.
*)

(* Variation stuff - should be deleted -- CH: ha? it seems used *)
Inductive Variation {A : Type} :=
| Var : Label -> A -> A -> Variation.

Class ShrinkV (A : Type) := { shrinkV : @Variation A -> list (@Variation A) }.
(* End of to be deleted *)

Definition validJump (st : SState) (addr : Z) :=
  let '(St imem _ _ _ _) := st in
  ((Z.to_nat addr) <? (List.length imem))%nat.
