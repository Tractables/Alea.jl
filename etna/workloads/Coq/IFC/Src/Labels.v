Require Import ZArith.

From mathcomp Require Import ssreflect ssrfun ssrbool ssrnat eqtype seq.

Require Import Utils.

(** The four point finite lattice (diamond shape) *)
Inductive Label : Set :=
  | L  : Label
  | M1 : Label
  | M2 : Label
  | H  : Label.


Definition bot := L.

Definition join l1 l2 :=
     match l1, l2 with
       | _ , H  => H
       | H , _  => H
       | L , _  => l2
       | _ , L  => l1
       | M1, M2 => H
       | M2, M1 => H
       | _ , _  => l1 (* l1 == l2 *)
     end.

Definition flows l1 l2 :=
    match l1, l2 with
      | L , L  => true
      | L , M1 => true
      | L , M2 => true
      | L , H  => true
      | M1, M1 => true
      | M1, H  => true
      | M2, M2 => true
      | M2, H  => true
      | H , H  => true
      | _ , _  => false
    end.

Definition meet l1 l2 :=
     match l1, l2 with
       | _ , L  => L
       | L , _  => L
       | H , _  => l2
       | _ , H  => l1
       | M1, M2 => L
       | M2, M1 => L
       | _ , _  => l1 (* l1 == l2 *)
     end.

Definition bot_flows : forall l, flows bot l = true.
Proof. now intros l; destruct l; auto. Qed.

Definition flows_refl : forall l, flows l l = true.
Proof. now intros l; destruct l; auto. Qed.

Definition flows_trans : forall l1 l2 l3, flows l1 l2 = true ->
                                 flows l2 l3 = true ->
                                 flows l1 l3 = true.
Proof. now intros l1 l2 l3; destruct l1, l2, l3; auto. Qed.

Definition flows_antisymm : forall l1 l2, flows l1 l2 = true ->
                                 flows l2 l1 = true -> l1 = l2.
Proof. now intros l1 l2; destruct l1, l2; auto. Qed.

Definition flows_join_right : forall l1 l2, flows l1 (join l1 l2) = true.
Proof. now intros l1 l2; destruct l1, l2; auto. Qed.

Definition flows_join_left : forall l1 l2, flows l2 (join l1 l2) = true.
Proof. now intros l1 l2; destruct l1, l2; auto. Qed.

Definition join_minimal : forall l1 l2 l, flows l1 l = true ->
                                 flows l2 l = true ->
                                 flows (join l1 l2) l = true.
Proof. intros l1 l2 l; destruct l1, l2, l; auto. Qed.

Notation "l1 \_/ l2" := (join l1 l2) (at level 40) : type_scope.
Notation "l1 <: l2" := (flows l1 l2 = true)
  (at level 50, no associativity) : type_scope.
Notation "⊥" := bot.

Hint Resolve
  @flows_refl
  @flows_trans
  @flows_join_left
  @flows_join_right
  @flows_antisymm
  @join_minimal : lat.

Definition flows_to (l1 l2 : Label) : Z :=
  if flows l1 l2 then 1%Z else 0%Z.

Lemma flows_join : forall l1 l2,
  l1 <: l2 <-> l1 \_/ l2 = l2.
Proof.
  intros.
  split.
  - intros H.
    apply flows_antisymm.
    + apply join_minimal; auto with lat.
    + apply flows_join_left.
  - intros H.
    rewrite <- H.
    auto with lat.
Qed.

Lemma join_1_rev : forall l1 l2 l,
  l1 \_/ l2 <: l -> l1 <: l.
Proof. eauto with lat. Qed.

Lemma join_2_rev : forall l1 l2 l,
  l1 \_/ l2 <: l -> l2 <: l.
Proof. eauto with lat. Qed.

Lemma join_1 : forall l l1 l2,
  l <: l1 -> l <: l1 \_/ l2.
Proof. eauto with lat. Qed.

Lemma join_2 : forall l l1 l2,
  l <: l2 -> l <: l1 \_/ l2.
Proof. eauto with lat. Qed.

Lemma join_bot_right : forall l,
  l \_/ bot = l.
Proof.
  eauto using bot_flows with lat.
Qed.

Lemma join_bot_left : forall l,
  bot \_/ l = l.
Proof. eauto using bot_flows with lat.
Qed.

Lemma not_flows_not_join_flows_left : forall l l1 l2,
  flows l1 l = false ->
  flows (l1 \_/ l2) l = false.
Proof.
  intros.
  destruct (flows (l1 \_/ l2) l) eqn:E.
  exploit join_1_rev; eauto.
  auto.
Qed.

Lemma not_flows_not_join_flows_right : forall l l1 l2,
  flows l2 l = false ->
  flows (l1 \_/ l2) l = false.
Proof.
  intros.
  destruct (flows (l1 \_/ l2) l) eqn:E.
  exploit join_2_rev; eauto.
  auto.
Qed.

Definition label_eqb l1 l2 := flows l1 l2 && flows l2 l1.

Lemma label_eqP : Equality.axiom label_eqb.
Proof.
move => l1 l2.
rewrite /label_eqb.
apply/(iffP idP).
- move/andP => [H1 H2].
  by apply flows_antisymm.
- move => -> .
  by rewrite !flows_refl.
Qed.

Definition label_eqMixin := EqMixin label_eqP.

Hint Resolve
  @join_1
  @join_2
  @bot_flows
  @not_flows_not_join_flows_right
  @not_flows_not_join_flows_left : lat.

Definition label_dec 
  : forall l1 l2 : Label, {l1 = l2} + {l1 <> l2}.
Proof.
  intros x y.
  destruct (flows x y) eqn:xy;
  destruct (flows y x) eqn:yx; try (right; congruence).
  - left. eauto with lat.
  - generalize (flows_refl x). intros.
    right. congruence.
Defined.

Definition top := H.

Definition flows_top : forall l, l <: top.
Proof. intros l; destruct l; auto. Defined.

Module Import LabelEqType.

Canonical label_eqType := Eval hnf in EqType _ label_eqMixin.

End LabelEqType.

Definition all_labels := [:: L;M1;M2;H].

Definition allThingsBelow (l : Label) : list Label :=
  filter (fun l' => flows l' l) all_labels.

Definition all_labels_correct : forall l, l \in all_labels.
Proof. by case. Defined.


From QuickChick Require Import QuickChick.
Derive Show for Label.
Derive Arbitrary for Label.
(* Derive Fuzzy for Label.*)
