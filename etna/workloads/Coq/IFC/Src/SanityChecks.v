
From QuickChick Require Import QuickChick.

Require Import Reachability.
Require Import Printing.
Require Import Indist.
Require Import Machine.

Require Import List. Import ListNotations.
Require Import TestingCommon.
Require Import Coq.Strings.String.

From mathcomp Require Import ssreflect ssrbool eqtype.

Local Open Scope string.




  (*
  Definition propStampGeneration (st : SState) :=
    let stamps := generateStamps st in
    whenFail (Checker.trace ("Generated: " ++ nl ++
                             (showStamps (allocated (st_mem st)) stamps)))
             (wellFormed st stamps).
  *)

  Definition prop_generate_indist (lab: Label) (st1 st2: SState): bool :=
    (indist lab st1 st2).

  Definition prop_fstep_preserves_well_formed (t : table) (st: SState) : bool :=
    well_formed st -=>
      match fstep t st with
      | Some st' => (well_formed st')
      | _ => false
      end.

  (*
(* This is trivial, but it was mentioned below so I've proved it *)
Lemma prop_stamp_generation_equiv :
  semCheckable prop_stamp_generation <->
  (forall st, semGen genSState st -> well_formed st).
Abort.
(* Proof. *)
(*   rewrite /prop_stamp_generation /semCheckable /checker /testFun. *)
(*   rewrite semForAllShrink. split => H st gen. *)
(*   - specialize (H st gen). by move /semPredQProp/semBool in H. *)
(*   - rewrite semPredQProp. apply /semBool. apply H. exact gen. *)
(* Qed. *)

(* One more rather trivial one;
   TODO both these would become more interesting if we had declarative
        variants of well_formed and indist *)
Lemma prop_generate_indist_equiv :
  semCheckable prop_generate_indist <->
  (forall lab st1 st2,
     semGen gen_variation_SState (Var lab st1 st2) -> indist lab st1 st2).
Abort.
(* Proof. *)
(*   rewrite /prop_generate_indist. rewrite semPredQProp. *)
(*   setoid_rewrite semForAllShrink. *)
(*   split => [H lab st1 st2 gen | H [lab st1 st2] gen]. *)
(*   - specialize (H (Var lab st1 st2) gen). red in H. *)
(*     by move /semPredQProp/semBool in H. *)
(*   - rewrite semPredQProp. apply semBool. by apply H. *)
(* Qed. *)

(* One direction of this (soundness) is checked by prop_stamp_generation above;
   this is the high-level spec we need for genSState
   TODO: move this to GenerationProofs? *)
Lemma genSState_well_formed : forall st,
  semGen genSState st <-> well_formed st.
Abort.

Definition fstep_preserves_well_formed : Prop := forall st st',
  well_formed st ->
  fstep default_table st = Some st' ->
  well_formed st'.

Lemma prop_fstep_preserves_well_formed_equiv :
    semChecker (prop_fstep_preserves_well_formed default_table) <->
    fstep_preserves_well_formed.
Abort.
(* Proof. *)
(*   rewrite /prop_fstep_preserves_well_formed /fstep_preserves_well_formed *)
(*     semForAllShrink /arbitrary /arbSState. setoid_rewrite semPredQProp. *)
(*   split => [H st st' wf ex | H st arb]. *)
(*   - assert (@genSState Pred _ st) as gs by (by rewrite genSState_well_formed). *)
(*     specialize (H st gs). *)
(*     rewrite wf ex in H. *)
(*     (* by move /semWhenFail_id /semBool in H. *)     *)
(*     by apply semBool in H. *)
(*   - move /genSState_well_formed in arb. rewrite arb. specialize (H st). *)
(*     move : H. case (fstep default_table st) => [ st' | ] H. *)
(*     + specialize (H st' arb Logic.eq_refl). rewrite H. *)
(*       (* rewrite semWhenFail_id. by rewrite <- semBool. *) *)
(*       by apply <- semBool. *)
(*     + fold (semCheckable rejected). rewrite semResult. reflexivity. *)
(* Qed. *)
*)

