Require Import Coq.Strings.String.
Require Import Arith.EqNat.
Require Import ZArith.

From QuickChick Require Import QuickChick.

Require Import Machine.
Require Import TestingCommon.
Require Import Printing.

Open Scope string_scope.

Require Import Reachability.

Definition is_low_SState st lab := isLow (pc_lab (st_pc st)) lab.


Definition propSSNI_smart (t : table) (v : Variation) : option bool :=
    let '(Var lab st1 st2) := v in
    if indist lab st1 st2 && well_formed st1 && well_formed st2 then
      match fstep t st1  with
      | Some st1' =>
        if is_low_SState st1 lab then
          match fstep t st2 with
          | Some st2' => Some (indist lab st1' st2' && well_formed st1' && well_formed st2')
          | _ => None
          end
        else (* is_high st1 *)
          if is_low_SState st1' lab then
            match fstep t st2 with
            | Some st2' =>
              if is_low_SState st2' lab then
                Some (indist lab st1' st2' && well_formed st1' && well_formed st2')
              else Some true
            | _ => None
            end
          else
            Some (indist lab st1 st1' && well_formed st1')
      | _ => None
      end
    else None.