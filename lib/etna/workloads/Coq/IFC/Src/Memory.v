Require Import Datatypes.
Require Import ZArith.
Require Import Coq.Strings.String.
Require Import Lia.


From QuickChick Require Import QuickChick.
From mathcomp Require Import ssreflect ssrfun ssrbool ssrnat eqtype seq.

Require Import Utils Labels.
Import LabelEqType.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

(* I'm ending the craziness. Label model is now fixed to be Lab4. *)
Inductive memframe A := Fr (lab : Label) : list A -> memframe A.

Derive Fuzzy for prod.
Derive Fuzzy for list.


Derive Fuzzy for Label.
Derive Fuzzy for memframe.

(* #[local] Instance Fuzzy_memframe {A} `{GenSized A} `{Fuzzy A}: Fuzzy (memframe A) :=
  {| fuzz n := 
    match n with
    | Fr la l => oneOf_ (ret n) (cons (bindGen (fuzz l) (fun l' => returnGen (Fr la l'))) (cons (bindGen (fuzz la) (fun la' => returnGen (Fr la' l))) (nil)))
    end
  |}.
 *)

Derive Arbitrary for memframe.
Derive Show for memframe. 

Section FrameEqType.

Variables A : eqType.

Definition memframe_eq (fr1 fr2 : @memframe A) : bool :=
  let: Fr l1 xs1 := fr1 in
  let: Fr l2 xs2 := fr2 in
  [&& l1 == l2 & xs1 == xs2].

Lemma memframe_eqP : Equality.axiom memframe_eq.
Proof.
move=> [l1 xs1] [l2 xs2]; apply/(iffP andP).
  by move=> [/eqP -> /eqP ->].
by move => [-> ->]; rewrite !eqxx.
Qed.

Definition memframe_eqMixin := EqMixin memframe_eqP.

Canonical memframe_eqType := Eval hnf in EqType (memframe A) memframe_eqMixin.

End FrameEqType.

Require Import Coq.Structures.Equalities.
Require Import Coq.Structures.DecidableTypeEx.
(* From QuickChick Require Import FMapWeakListInstances.*)
Require Import Coq.FSets.FMapFacts.

Module Lab_as_MDT <: MiniDecidableType.
  Definition t := Label.
  Definition eq_dec : forall x y : t, {x=y}+{~x=y}.
  Proof. decide equality. Defined.
End Lab_as_MDT.

Module Lab_as_UDT := Make_UDT(Lab_as_MDT).
  
Definition block := (Z * Lab_as_UDT.t)%type.

Definition block_eq (b1 b2 : block) := b1 == b2.

Lemma block_eqP : Equality.axiom block_eq.
Proof. unfold Equality.axiom. intros. exact /eqP. Defined.

Definition block_eqMixin := EqMixin block_eqP.
Canonical block_eqType := EqType block block_eqMixin.

Definition stamp : block -> Label := @snd _ _.
Definition put_stamp (s : Label) (b : block) : block :=
    let (z,_) := b in (z,s).


Module Type S (X : DecidableType).
  Include FMapInterface.WSfun X.

  Section elt.
    Variable elt : Type.
    Parameter from_list : list (X.t * elt) -> t elt.

    Declare Instance genSizedMap `{GenSized X.t} `{GenSized elt} : GenSized (t elt).
    Declare Instance shrinkMap `{Shrink X.t} `{Shrink elt} : Shrink (t elt).

    Declare Instance showMap `{Show X.t} `{Show elt} : Show (t elt).

   Declare Instance fuzzyMap `{GenSized X.t} `{GenSized elt} `{Fuzzy X.t} `{Fuzzy elt} : Fuzzy (t elt).

  End elt.

End S.

Import MonadNotation.
Local Open Scope monad_scope.

Require FMapWeakList.
Module Make (X : DecidableType) <: S X.
  Include FMapWeakList.Make X.

  Section elt.
    Variable elt : Type.

    Definition from_list (l : list (X.t * elt)) : t elt :=
      List.fold_left (fun acc kv => add (fst kv) (snd kv) acc) l (empty elt).
  
    (* Generate two arbitrary vectors of the given sizefor keys and values,
       zip them together and build up into a map. *)
    Global Instance genSizedMap `{GenSized X.t} `{GenSized elt} : GenSized (t elt) :=
    {| arbitrarySized s := 
         keys <- vectorOf s (@arbitrarySized X.t _ s);;
         vals <- vectorOf s (@arbitrarySized elt _ s);;
         ret (from_list (combine keys vals))
    |}.

    (* The rest of the operations are derived from their list counterparts. *)
    Global Instance shrinkMap `{Shrink X.t} `{Shrink elt} : Shrink (t elt) :=
    {| shrink m := List.map from_list (shrink (elements m)) |}.

    Global Instance showMap `{Show X.t} `{Show elt} : Show (t elt) :=
    {| show m := show (elements m) |}.

    Global Instance fuzzyMap `{GenSized X.t} `{GenSized elt} `{Fuzzy X.t} `{Fuzzy elt} : Fuzzy (t elt) :=
    {| fuzz m :=
         m' <- fuzz (elements m);;
         ret (from_list m')
    |}.

  End elt.
End Make.


(* Memory is just a map from stamps to lists of data. *)
Module Lab_as_DT := UDT_to_DT (Lab_as_UDT).
Module Map := Make (Lab_as_DT).
Module MapFacts := WFacts_fun Map.E Map.
Definition mem A := Map.t (list (memframe A)).


Definition get_memframe {A} (m : mem A) (b : block) :=
    match Map.find (snd b) m with
    | Some bs => nth_error_Z bs (fst b)
    | None => None
    end.

Definition next {A} (m : mem A) (s : Label) : Z :=
    match Map.find s m with
    | Some bs => Z.of_nat (length bs)
    | None => Z0
    end.

Theorem get_memframe_next {A} : forall i s (m : mem A),
      (0 <= i < next m s)%Z <-> (exists fr, get_memframe m (i,s) = Some fr).
Proof.
    move => i s m; rewrite /next /get_memframe.
    simpl; destruct (Map.find s m) eqn:FindS.
    { split => Hyp.
    - apply nth_error_Z_valid2.
      destruct Hyp as [H1 H2].
      split; auto.
      apply /ltP.
      apply Z2Nat.inj_lt in H2; auto.
      { rewrite Nat2Z.id in H2; auto. }
      lia.
    - destruct Hyp as [fr Hfr].
      apply nth_error_Z_valid in Hfr.
      destruct Hfr as [H1 H2].
      split; auto.
      apply Z2Nat.inj_lt; auto.
      { apply Nat2Z.is_nonneg. }
      rewrite Nat2Z.id.
      apply /ltP.
      auto.
    }
    { split => Hyp.
      - lia.
      - destruct Hyp; congruence.
    } 
Qed.

Theorem next_pos : forall {A} (m : mem A) s, (0 <= next m s)%Z.
Proof.
    intros A m s.
    rewrite /next.
    destruct (Map.find s m).
    - apply Nat2Z.is_nonneg.
    - lia.
Qed.

(* Only used in QuickChick proofs *)
Definition memory_extensionality {A} (m1 m2 : mem A)
           (H : forall b, get_memframe m1 b = get_memframe m2 b) : m1 = m2.
  (* I think this can actually be proved now *)
  admit.
Admitted.

Definition Z_seq z1 z2 := map Z.of_nat (iota (Z.to_nat z1) (Z.to_nat z2)).

Definition get_blocks_at_level {A} (m : mem A) s:=
    let max := next m s in
    let indices := Z_seq 0%Z max in
    map (fun ind => (ind,s)) indices.

Definition get_blocks {A} (ss : list Label) (m : mem A) : list block :=
    flatten (map (get_blocks_at_level m) ss).

Instance show_block : Show block :=
  {|
    show b :=
      let (z,s) := (b : block) in
      ("(" ++ show z ++ " @ " ++ show s ++ ")")%string
  |}.

Instance gen_block : GenSized block :=
  {|
    arbitrarySized := fun n => liftGen2 pair (arbitrarySized n) (arbitrarySized n)
  |}.


Definition map {A B} (f:memframe A -> memframe B) (m:mem A) : mem B :=
  Map.map (List.map f) m.

Lemma MapsTo_In : forall {A} m k {v : A}, Map.MapsTo k v m -> Map.In k m.
Proof. intros; exists v; auto. Qed.

Lemma map_spec : forall A B (f:memframe A -> memframe B) (m:mem A),
    forall b, get_memframe (map f m) b = omap f (get_memframe m b).
Proof.
  intros.
  rewrite /get_memframe /map /omap /obind /oapp.
  destruct (Map.find b.2 m) eqn:Find.
  - remember Find as Maps. clear HeqMaps. apply Map.find_2 in Maps.
    apply Map.map_1 with (f := List.map f) in Maps.
    apply Map.find_1 in Maps.
    rewrite Maps.
    apply nth_error_Z_map.
  - destruct (Map.find b.2 (Map.map (List.map f) m)) as [? | ?] eqn:Contra; auto.
    apply Map.find_2 in Contra.
    apply MapsTo_In in Contra.
    apply Map.map_2 in Contra.
    destruct Contra as [x Hx].
    apply Map.find_1 in Hx.
    congruence.
Qed.

Definition empty A : mem A := Map.empty _.
  
Lemma get_empty : forall A b, get_memframe (empty A)  b = None.
Proof. auto. Qed.

  (* Program Definition init A S {eqS : EqDec S eq} (am : alloc_mode) b f : t A S:= MEM *)
  (*   (fun b' : block S => if b' == b then Some f else None) *)
  (*   (fun s => if s == stamp _ b then fst b + 1 else 1)%Z *)
  (*   _.  *)
  (* Next Obligation. *)
  (*   simpl in *. *)
  (*   destruct (s == s0) as [EQ | NEQ]. *)
  (*   - compute in EQ. subst s0. *)
  (*     destruct (equiv_dec (i,s)) as [contra|]; trivial. *)
  (*     inv contra. *)
  (*     omega. *)
  (*   - destruct (equiv_dec (i,s)) as [E|E]; try congruence. *)
  (* Qed. *)

  (* Lemma get_init_eq : forall A S {eqS:EqDec S eq} *)
  (*                            mode (b : block S) (f : @memframe A S), *)
  (*                       get_memframe (init A S mode b f) b = Some f. *)
  (* Proof. *)
  (*   unfold init. simpl. *)
  (*   intros. *)
  (*   match goal with *)
  (*     | |- context [if ?b then _ else _] => *)
  (*       destruct b; congruence *)
  (*   end. *)
  (* Qed. *)

  (* Lemma get_init_neq : forall A S {eqS:EqDec S eq} *)
  (*                             mode (b b' : block S) (f : @memframe A S), *)
  (*                        b' <> b -> *)
  (*                        get_memframe (init A S mode b f) b' = None. *)
  (* Proof. *)
  (*   unfold init. simpl. *)
  (*   intros. *)
  (*   match goal with *)
  (*     | |- context [if ?b then _ else _] => *)
  (*       destruct b; congruence *)
  (*   end. *)
  (* Qed. *)

Definition upd_memframe {A} (m:mem A) (b:block) (fr:memframe A) : option (mem A) :=
  let (i,s) := b in
  match Map.find s m with
  | None => None
  | Some l =>
    match update_list_Z l i fr with
    | Some l' => Some (Map.add s l' m)
    | None => None
    end
  end.

Lemma eq_refl_false : forall (A : eqType) (x : A), x == x = false -> False.
Proof. 
  move => A x H.
  pose proof (eq_refl x).
  congruence.
Qed.  

Lemma eq_refl_false_2 : forall (A : eqType) (x y : A), x == y = false -> x <> y.
Proof. 
  move => A x y H Contra; subst.
  eapply eq_refl_false; eauto.
Qed.  

Lemma eq_refl_true : forall (A : eqType) (x y : A), x == y = true -> x = y.
Proof. 
  move => A x y H.
  apply /eqP; auto.
Qed.  

Hint Resolve
     update_list_Z_spec
     update_list_Z_spec3
     nth_error_Z_length_none
  : listZ.

Ltac solver :=
    simpl in *;
    match goal with
    (* Destruct across matches and equalities to simplify terms. *)
    | [ H : context [match ?X with | Some _ => _ | None => _ end] |- _ ]  =>
      let C := fresh "Case" in
      destruct X eqn:C
    | [ |- context [match ?X with | Some _ => _ | None => _ end] ]  =>
      let C := fresh "Case" in
      destruct X eqn:C
    | [ |- context [if @eq_op ?EqT ?X ?Y then _ else _] ] =>
      let C := fresh "Eq" in
      destruct (@eq_op EqT X Y) eqn:C
    | [ H : context[Map.E.eq_dec ?S1 ?S2] |- _ ] =>
      destruct (Map.E.eq_dec S1 S2); subst
    (* Reflect equalities for subst. *)
    | [ H : (?X == ?Y) = true |- _ ] => apply eq_refl_true in H; inv H
    (* Some is injective *)       
    | [ H : Some ?X = Some ?Y |- _ ] => inv H
    | [ H : (_,_) = (_,_) |- _ ] => inv H
    (* Rewrite hypotheses with the same LHS. *)
    | [ H1 : ?X = Some ?Y1, H2 : ?X = Some ?Y2 |- _ ] =>
      rewrite H1 in H2; inv H2
    | [ H1 : ?X = Some ?Y1, H2 : ?X = None |- _ ] =>
      rewrite H1 in H2; inv H2
    (* Rewrite the find s (add s' m) pattern *)
    | [ H : context[Map.find ?S1 (Map.add ?S2 _ _)] |- _ ] =>
      rewrite MapFacts.add_o in H
    (* Discharge some easy contradictions. *)
    | [ H : (?X == ?X) = false |- _ ] => apply eq_refl_false in H; inv H
    | [ H : ?S <> ?S |- _ ] => exfalso; apply H; auto
    (* Lift inequality of pairs to inequality of first projection if possible. *)
    | [ H : (?I1, ?S) == (?I2, ?S) = false |- _ ] =>
      let N := fresh "NEq" in
      assert (N: I1 <> I2) by (move => ?; subst; apply eq_refl_false in H; inv H);
      clear H
    (* Resolve with spec2 to avoid infinite symmetry loop *)
    | [ H1 : update_list_Z ?L2 ?I ?Fr = Some ?L1
      , H2 : ?I1 <> ?I2
      |- nth_error_Z ?L1 ?I2 = nth_error_Z ?L2 ?I2 ] =>
      eapply update_list_Z_spec2 in H1; eauto
    (* Resolve contradiction using valid_update *)
    | [ H1 : nth_error_Z ?L ?I = Some _
      , H2 : update_list_Z ?L ?I ?Fr = None
      |- _ ] => apply valid_update with (x' := Fr) in H1; move: H1 => [? ?]
    end;
    (* Finish with eauto + list_Z hint database *)
    eauto with listZ.

Lemma upd_get_memframe : forall A (m:mem A) (b:block) fr fr',
    get_memframe m b = Some fr ->
    exists m', upd_memframe m b fr' = Some m'.
Proof.
  rewrite /upd_memframe /get_memframe => A m [i s] fr fr' HGet; simpl in *.
  repeat solver; try congruence.
Qed.

Lemma get_upd_memframe : forall A (m m':mem A) (b:block) fr,
    upd_memframe m b fr = Some m' ->
    forall b',
      get_memframe m' b' = if b == b' then Some fr else get_memframe m b'.
Proof.
  rewrite /upd_memframe /get_memframe => A m m' [i s] fr Hupd [i' s'] //=.
  repeat solver; try congruence.
Qed.

Lemma upd_memframe_defined : forall A (m m':mem A) (b:block) fr,
    upd_memframe m b fr = Some m' ->
    exists fr', get_memframe m b = Some fr'.
Proof.
  rewrite /upd_memframe /get_memframe => A m m' [i s] fr Upd.
  repeat solver; try congruence.
Qed.

Opaque Z.add.

Definition alloc {A} (m:mem A) (s:Label) (fr:memframe A)
  : (block * mem A) :=
  match Map.find s m with
  | Some l =>
    let i := Z.of_nat (length l) in
    ((i, s), Map.add s (l ++ [:: fr]) m)
  | None =>
    ((Z0, s), Map.add s [:: fr] m)
  end.

Lemma alloc_stamp : forall A (m m':mem A) s fr b,
    alloc m s fr = (b,m') -> stamp b = s.
Proof.
  rewrite /alloc => A m m' s fr b HAlloc.
  repeat solver.
Qed.

Lemma alloc_get_fresh : forall A (m m':mem A) s fr b,
    alloc m s fr = (b,m') -> get_memframe m b = None.
Proof.
  rewrite /alloc /get_memframe => A m m' s' fr [i s] HAlloc //=.
  repeat solver.
Qed.

Lemma alloc_get_memframe : forall A (m m':mem A) s0 fr b,
    alloc m s0 fr = (b,m') ->
    forall b', get_memframe m' b' = if b == b' then Some fr else get_memframe m b'.
Proof.
  rewrite /alloc /get_memframe => A m m' s0 fr [i s] HAlloc [i' s'] //=.
  repeat solver; try congruence.
  - apply nth_error_Z_app; auto.
  - move: (nth_error_Z_snoc l1 fr i') => [Contra | ?]; auto.
    rewrite -Contra in NEq.
    exfalso; eauto.
  - destruct i'; auto;
      try solve [exfalso; eauto].
    { (* Should be moved *)
          rewrite /nth_error_Z.
          destruct (Z.pos p <? 0)%Z; auto.
          destruct (Z.to_nat (Z.pos p)) eqn:Contra; simpl; auto.
          - rewrite Z2Nat.inj_pos in Contra.
            pose proof (Pos2Nat.is_pos p).
            lia.
          - destruct n; auto.
    }
Qed.

Lemma alloc_upd : forall A (m:mem A) b fr1 s fr2 m',
    upd_memframe m b fr1 = Some m' ->
    fst (alloc m' s fr2) = fst (alloc m s fr2).
Proof.
  rewrite /alloc /upd_memframe => A m [i s] fr1 s' fr2 m' H.
  repeat solver; try congruence.
  erewrite update_preserves_length_Z; eauto.
Qed.

Lemma alloc_local :
    forall A (m1 m2:mem A) s fr1 fr2,
      (forall b, stamp b = s -> get_memframe m1 b = get_memframe m2 b :> bool) ->
      (alloc m1 s fr1).1 = (alloc m2 s fr2).1.
Proof.
  rewrite /get_memframe /alloc => A m1 m2 s fr1 fr2 H.
  repeat solver; simpl.
  - f_equal. f_equal.
    apply nth_error_Z_length_ext => i.
    specialize (H (i,s)).
      simpl in *.
      rewrite Case in H.
      rewrite Case0 in H.
      apply H; auto.
  - specialize (H (0%Z,s)).
    simpl in *.
    rewrite Case Case0 in H.
    destruct l; simpl in *; simpl in *; auto.
    compute in H.
    specialize (H Coq.Init.Logic.eq_refl).
    congruence.
  - specialize (H (0%Z,s)).
    simpl in *.
    rewrite Case Case0 in H.
    destruct l; simpl in *; simpl in *; auto.
    compute in H.
    specialize (H Coq.Init.Logic.eq_refl).
    congruence.
Qed.

Lemma in_seq_Z:
  forall z start len,
    (0 <= start)%Z ->
      (0 <= len)%Z ->
      ((start <= z < len + start)%Z <->
       z \in (Z_seq start len)).
Proof.
    intros z s l. intros Hle1 Hle2. split.
    - intros [H1 H2]. unfold Z_seq.
      apply/mapP. exists (Z.to_nat z); last by rewrite Z2Nat.id; lia.
      apply Z2Nat.inj_lt in H2; try lia.
      rewrite Z2Nat.inj_add in H2; try lia.
      apply Z2Nat.inj_le in H1; try lia.
      apply Z2Nat.inj_le in Hle1; try lia.
      apply Z2Nat.inj_le in Hle2; try lia.
      simpl in *. remember (Z.to_nat s) as start.
      remember (Z.to_nat l) as len.
      remember (Z.to_nat z) as z'. clear Heqlen l Heqstart s Heqz' z Hle1.
      generalize dependent start. generalize dependent z'.
      induction len as [| l IHl]; intros s start Hle1 Hle3.
      + lia.
      + simpl in *. apply le_lt_or_eq in Hle1. destruct Hle1 as [H1 | H2].
        rewrite inE; apply/orP; right. apply IHl; try lia.
        rewrite inE; apply/orP; left; apply/eqP; congruence.
    - intros HIn. unfold Z_seq in HIn.
      move/mapP in HIn. destruct HIn as [z' HIn Heq]. subst.
      assert (H: Z.to_nat s <= z' < (Z.to_nat l) + (Z.to_nat s) ->
                 (s <= (Z.of_nat z') < l + s)%Z).
      { move=> /andP [H1 H2]. split.
        apply Z2Nat.inj_le; try lia. rewrite Nat2Z.id. apply/leP. assumption.
        apply Z2Nat.inj_lt; try lia. rewrite Nat2Z.id Z2Nat.inj_add;
         try lia. apply/ltP. assumption. }
      apply H.
      apply Z2Nat.inj_le in Hle1; try lia.
      apply Z2Nat.inj_le in Hle2; try lia.
      remember (Z.to_nat s) as start.
      remember (Z.to_nat l) as len.
      clear H Heqlen l Heqstart s.
      generalize dependent start. generalize dependent z'.
      induction len as [| len IHlen].
      + by [].
      + intros z' start Hle; rewrite /= inE => /orP HIn. simpl in *.
        case: HIn => [/eqP ?|HIn]; subst.
          rewrite addnE /addn_rec; apply/andP; split; [apply/leP|apply/ltP]; lia.
        * rewrite addSn -addnS.
        assert (H': S start <= z' < len + S start ->
                    start <= z' < len + S start).
        { rewrite addnE /addn_rec.
          move=> /andP [/leP H1 /ltP H2].
          apply/andP; split; [apply/leP| apply/ltP]; try lia. }
        apply H'. apply IHlen; try lia. assumption.
Qed.

Lemma get_blocks_spec :
    forall A (labs : list Label) (mem: mem A) b,
      (stamp b \in labs) && get_memframe mem b <->
      b \in get_blocks labs mem.
Proof.
  intros A labs mem b; split.
    - case/andP => HIn.
      case Hget: get_memframe => [fr|] //= _.
      unfold get_blocks; apply/flatten_mapP.
      eexists; [eassumption|].
      unfold get_blocks_at_level. apply/mapP. exists b.1;
      destruct b=> //.
      apply in_seq_Z; try lia; simpl in *.
      * apply next_pos.
      * rewrite Z.add_0_r.
        apply get_memframe_next. eexists. eassumption.
    - intros HIn. unfold get_blocks, get_blocks_at_level in *.
      move/flatten_mapP in HIn. destruct HIn as [l HInl HIn].
      move/mapP in HIn. destruct HIn as [z HIn Heq]. subst.
      rewrite HInl /=.
      unfold get_memframe.
      simpl in *.
      apply in_seq_Z in HIn; try lia.
      * rewrite Z.add_0_r in HIn. apply get_memframe_next in HIn.
        move: HIn => [fr H].
        rewrite /get_memframe in H.
        simpl in *.
        destruct (Map.find l mem).
        + rewrite H; auto.
        + congruence.
      * apply next_pos.
Qed.

Lemma alloc_get_memframe_old :
  forall T mem (stamp : Label) (f f' : memframe T) b b' mem'
         (ALLOC : alloc mem stamp f' = (b', mem'))
         (MEMFRAME : get_memframe mem b = Some f),
    get_memframe mem' b = Some f.
Proof.
  intros.
  erewrite alloc_get_memframe; eauto.
  have [e|//] := altP (b' =P b).
  exploit alloc_get_fresh; eauto.
  congruence.
Qed.

Lemma alloc_get_memframe_new :
  forall T mem (stamp : Label) (memframe : memframe T) b mem'
         (ALLOC : alloc mem stamp memframe = (b, mem')),
    get_memframe mem' b = Some memframe.
Proof.
  intros.
  erewrite alloc_get_memframe; eauto.
  by rewrite eqxx; simpl in *; auto.
Qed.

Lemma get_memframe_upd_memframe_eq :
  forall T 
         (m : mem T) b f m'
         (UPD : upd_memframe m b f = Some m'),
    get_memframe m' b = Some f.
Proof.
  intros.
  erewrite get_upd_memframe; eauto.
  by rewrite eqxx.
Qed.

Lemma get_memframe_upd_memframe_neq :
  forall T 
         (m : mem T) b b' f m'
         (UPD : upd_memframe m b f = Some m')
         (NEQ : b' <> b),
    get_memframe m' b' = get_memframe m b'.
Proof.
  intros.
  erewrite get_upd_memframe; eauto.
  have [?|?] := (b =P b'); simpl in *; congruence.
Qed.
