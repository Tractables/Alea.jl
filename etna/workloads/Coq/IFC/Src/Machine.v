Require Import ZArith.

From mathcomp Require Import ssreflect ssrbool eqtype seq.

Require Import Utils. Import DoNotation. 
Require Import Labels.
Import LabelEqType.

Require Import Rules.
Require Import Memory.
Require Import Instructions.


(** Rule Table *)

Local Open Scope nat.
Definition labelCount (c:OpCode) : nat :=
  match c with
  | OpLab     => 0
  | OpMLab    => 2
  | OpPcLab   => 0
  | OpBCall   => 2
  | OpBRet    => 3
  | OpPutLab  => 0
  | OpNop     => 0
  | OpPut     => 0
  | OpBinOp   => 2
  | OpJump    => 1
  | OpBNZ     => 1
  | OpLoad    => 3
  | OpStore   => 3
  | OpWrite   => 4
  | OpAlloc   => 3
  | OpPSetOff => 2
  | OpPGetOff => 1
  | OpMSize   => 2
  | OpMov     => 1
end.

Definition table := forall op, AllowModify (labelCount op).

Definition default_table : table := fun op =>
  match op with

(* ---"OpLab"--- *)

(*! *)
| OpLab => ≪ TRUE , BOT , LabPC ≫
(*!! OpLab_1 *)
(*! | OpLab => ≪ TRUE , BOT , BOT ≫ *)

(* ---"OpMLab"--- *)

(*! *)
| OpMLab => ≪ TRUE , Lab1 , LabPC ≫
(*!! OpMLab_1 *)
(*! | OpMLab => ≪ TRUE , BOT , LabPC ≫ *)
(*!! OpMLab_2 *)
(*! | OpMLab => ≪ TRUE , Lab1 , BOT ≫ *)

(* ---"OpPcLab"--- *)

(*! *)
| OpPcLab => ≪ TRUE , BOT , LabPC ≫
(*!! OpPcLab_1 *)
(*! | OpPcLab => ≪ TRUE , BOT , BOT ≫ *)

(* ---"OpBCall"--- *)

(*! *)
| OpBCall => ≪ TRUE , JOIN (Lab2) (LabPC) , JOIN (Lab1) (LabPC) ≫
(*!! OpBCall_1 *)
(*! | OpBCall => ≪ TRUE , BOT , JOIN (Lab1) (LabPC) ≫ *)
(*!! OpBCall_2 *)
(*! | OpBCall => ≪ TRUE , Lab2 , JOIN (Lab1) (LabPC) ≫ *)
(*!! OpBCall_3 *)
(*! | OpBCall => ≪ TRUE , LabPC , JOIN (Lab1) (LabPC) ≫ *)
(*!! OpBCall_4 *)
(*! | OpBCall => ≪ TRUE , JOIN (Lab2) (LabPC) , BOT ≫ *)
(*!! OpBCall_5 *)
(*! | OpBCall => ≪ TRUE , JOIN (Lab2) (LabPC) , Lab1 ≫ *)
(*!! OpBCall_6 *)
(*! | OpBCall => ≪ TRUE , JOIN (Lab2) (LabPC) , LabPC ≫ *)

(* ---"OpBRet"--- *)

(*! *)
| OpBRet => ≪ LE (JOIN (Lab1) (LabPC)) (JOIN (Lab2) (Lab3)) , Lab2 , Lab3 ≫
(*!! OpBRet_1 *)
(*! | OpBRet => ≪ TRUE , Lab2 , Lab3 ≫ *)
(*!! OpBRet_2 *)
(*! | OpBRet => ≪ LE (Lab1) (Lab2) , Lab2 , Lab3 ≫ *)
(*!! OpBRet_3 *)
(*! | OpBRet => ≪ LE (Lab1) (Lab3) , Lab2 , Lab3 ≫ *)
(*!! OpBRet_4 *)
(*! | OpBRet => ≪ LE (Lab1) (JOIN (Lab2) (Lab3)) , Lab2 , Lab3 ≫ *)
(*!! OpBRet_5 *)
(*! | OpBRet => ≪ LE (LabPC) (Lab2) , Lab2 , Lab3 ≫ *)
(*!! OpBRet_6 *)
(*! | OpBRet => ≪ LE (LabPC) (Lab3) , Lab2 , Lab3 ≫ *)
(*!! OpBRet_7 *)
(*! | OpBRet => ≪ LE (LabPC) (JOIN (Lab2) (Lab3)) , Lab2 , Lab3 ≫ *)
(*!! OpBRet_8 *)
(*! | OpBRet => ≪ LE (JOIN (Lab1) (LabPC)) (Lab2) , Lab2 , Lab3 ≫ *)
(*!! OpBRet_9 *)
(*! | OpBRet => ≪ LE (JOIN (Lab1) (LabPC)) (Lab3) , Lab2 , Lab3 ≫ *)
(*!! OpBRet_10 *)
(*! | OpBRet => ≪ LE (JOIN (Lab1) (LabPC)) (JOIN (Lab2) (Lab3)) , BOT , Lab3 ≫ *)
(*!! OpBRet_11 *)
(*! | OpBRet => ≪ LE (JOIN (Lab1) (LabPC)) (JOIN (Lab2) (Lab3)) , Lab2 , BOT ≫ *)

(* ---"OpPutLab"--- *)

(*! *)
| OpPutLab => ≪ TRUE , BOT , LabPC ≫
(*!! OpPutLab_1 *)
(*! | OpPutLab => ≪ TRUE , BOT , BOT ≫ *)

(* ---"OpNop"--- *)

(*! *)
| OpNop => ≪ TRUE , __ , LabPC ≫
(*!! OpNop_1 *)
(*! | OpNop => ≪ TRUE , __ , BOT ≫ *)

(* ---"OpPut"--- *)

(*! *)
| OpPut => ≪ TRUE , BOT , LabPC ≫
(*!! OpPut_1 *)
(*! | OpPut => ≪ TRUE , BOT , BOT ≫ *)

(* ---"OpBinOp"--- *)

(*! *)
| OpBinOp => ≪ TRUE , JOIN (Lab1) (Lab2) , LabPC ≫
(*!! OpBinOp_1 *)
(*! | OpBinOp => ≪ TRUE , BOT , LabPC ≫ *)
(*!! OpBinOp_2 *)
(*! | OpBinOp => ≪ TRUE , Lab1 , LabPC ≫ *)
(*!! OpBinOp_3 *)
(*! | OpBinOp => ≪ TRUE , Lab2 , LabPC ≫ *)
(*!! OpBinOp_4 *)
(*! | OpBinOp => ≪ TRUE , JOIN (Lab1) (Lab2) , BOT ≫ *)

(* ---"OpJump"--- *)

(*! *)
| OpJump => ≪ TRUE , __ , JOIN (LabPC) (Lab1) ≫
(*!! OpJump_1 *)
(*! | OpJump => ≪ TRUE , __ , BOT ≫ *)
(*!! OpJump_2 *)
(*! | OpJump => ≪ TRUE , __ , LabPC ≫ *)
(*!! OpJump_3 *)
(*! | OpJump => ≪ TRUE , __ , Lab1 ≫ *)

(* ---"OpBNZ"--- *)

(*! *)
| OpBNZ => ≪ TRUE , __ , JOIN (Lab1) (LabPC) ≫
(*!! OpBNZ_1 *)
(*! | OpBNZ => ≪ TRUE , __ , BOT ≫ *)
(*!! OpBNZ_2 *)
(*! | OpBNZ => ≪ TRUE , __ , Lab1 ≫ *)
(*!! OpBNZ_3 *)
(*! | OpBNZ => ≪ TRUE , __ , LabPC ≫ *)

(* ---"OpLoad"--- *)

(*! *)
| OpLoad => ≪ TRUE , Lab3 , JOIN (LabPC) (JOIN (Lab1) (Lab2)) ≫
(*!! OpLoad_1 *)
(*! | OpLoad => ≪ TRUE , BOT , JOIN (LabPC) (JOIN (Lab1) (Lab2)) ≫ *)
(*!! OpLoad_2 *)
(*! | OpLoad => ≪ TRUE , Lab3 , BOT ≫ *)
(*!! OpLoad_3 *)
(*! | OpLoad => ≪ TRUE , Lab3 , LabPC ≫ *)
(*!! OpLoad_4 *)
(*! | OpLoad => ≪ TRUE , Lab3 , JOIN (Lab1) (Lab2) ≫ *)

(* ---"OpStore"--- *)

(*! *)
| OpStore => ≪ LE (JOIN (Lab1) (LabPC)) (Lab2) , Lab3 , LabPC ≫
(*!! OpStore_1 *)
(*! | OpStore => ≪ TRUE , Lab3 , LabPC ≫ *)
(*!! OpStore_2 *)
(*! | OpStore => ≪ LE (Lab1) (Lab2) , Lab3 , LabPC ≫ *)
(*!! OpStore_3 *)
(*! | OpStore => ≪ LE (LabPC) (Lab2) , Lab3 , LabPC ≫ *)
(*!! OpStore_4 *)
(*! | OpStore => ≪ LE (JOIN (Lab1) (LabPC)) (Lab2) , BOT , LabPC ≫ *)
(*!! OpStore_5 *)
(*! | OpStore => ≪ LE (JOIN (Lab1) (LabPC)) (Lab2) , Lab3 , BOT ≫ *)

(* ---"OpWrite"--- *)

(*! *)
| OpWrite => ≪ LE (JOIN (JOIN (LabPC) (Lab1)) (Lab3)) (JOIN (Lab2) (Lab4)) , Lab4 , LabPC ≫
(*!! OpWrite_1 *)
(*! | OpWrite => ≪ TRUE , Lab4 , LabPC ≫ *)
(*!! OpWrite_2 *)
(*! | OpWrite => ≪ LE (JOIN (LabPC) (Lab1)) (Lab2) , Lab4 , LabPC ≫ *)
(*!! OpWrite_3 *)
(*! | OpWrite => ≪ LE (JOIN (LabPC) (Lab1)) (Lab4) , Lab4 , LabPC ≫ *)
(*!! OpWrite_4 *)
(*! | OpWrite => ≪ LE (JOIN (LabPC) (Lab1)) (JOIN (Lab2) (Lab4)) , Lab4 , LabPC ≫ *)
(*!! OpWrite_5 *)
(*! | OpWrite => ≪ LE (Lab3) (Lab2) , Lab4 , LabPC ≫ *)
(*!! OpWrite_6 *)
(*! | OpWrite => ≪ LE (Lab3) (Lab4) , Lab4 , LabPC ≫ *)
(*!! OpWrite_7 *)
(*! | OpWrite => ≪ LE (Lab3) (JOIN (Lab2) (Lab4)) , Lab4 , LabPC ≫ *)
(*!! OpWrite_8 *)
(*! | OpWrite => ≪ LE (JOIN (JOIN (LabPC) (Lab1)) (Lab3)) (Lab2) , Lab4 , LabPC ≫ *)
(*!! OpWrite_9 *)
(*! | OpWrite => ≪ LE (JOIN (JOIN (LabPC) (Lab1)) (Lab3)) (Lab4) , Lab4 , LabPC ≫ *)
(*!! OpWrite_10 *)
(*! | OpWrite => ≪ LE (JOIN (JOIN (LabPC) (Lab1)) (Lab3)) (JOIN (Lab2) (Lab4)) , BOT , LabPC ≫ *)
(*!! OpWrite_11 *)
(*! | OpWrite => ≪ LE (JOIN (JOIN (LabPC) (Lab1)) (Lab3)) (JOIN (Lab2) (Lab4)) , Lab4 , BOT ≫ *)

(* ---"OpAlloc"--- *)

(*! *)
| OpAlloc => ≪ TRUE , JOIN (Lab1) (Lab2) , LabPC ≫
(*!! OpAlloc_1 *)
(*! | OpAlloc => ≪ TRUE , BOT , LabPC ≫ *)
(*!! OpAlloc_2 *)
(*! | OpAlloc => ≪ TRUE , Lab1 , LabPC ≫ *)
(*!! OpAlloc_3 *)
(*! | OpAlloc => ≪ TRUE , Lab2 , LabPC ≫ *)
(*!! OpAlloc_4 *)
(*! | OpAlloc => ≪ TRUE , JOIN (Lab1) (Lab2) , BOT ≫ *)

(* ---"OpPSetOff"--- *)

(*! *)
| OpPSetOff => ≪ TRUE , JOIN (Lab1) (Lab2) , LabPC ≫
(*!! OpPSetOff_1 *)
(*! | OpPSetOff => ≪ TRUE , BOT , LabPC ≫ *)
(*!! OpPSetOff_2 *)
(*! | OpPSetOff => ≪ TRUE , Lab1 , LabPC ≫ *)
(*!! OpPSetOff_3 *)
(*! | OpPSetOff => ≪ TRUE , Lab2 , LabPC ≫ *)
(*!! OpPSetOff_4 *)
(*! | OpPSetOff => ≪ TRUE , JOIN (Lab1) (Lab2) , BOT ≫ *)

(* ---"OpPGetOff"--- *)

(*! *)
| OpPGetOff => ≪ TRUE , Lab1 , LabPC ≫
(*!! OpPGetOff_1 *)
(*! | OpPGetOff => ≪ TRUE , BOT , LabPC ≫ *)
(*!! OpPGetOff_2 *)
(*! | OpPGetOff => ≪ TRUE , Lab1 , BOT ≫ *)

(* ---"OpMSize"--- *)

(*! *)
| OpMSize => ≪ TRUE , Lab2 , JOIN (LabPC) (Lab1) ≫
(*!! OpMSize_1 *)
(*! | OpMSize => ≪ TRUE , BOT , JOIN (LabPC) (Lab1) ≫ *)
(*!! OpMSize_2 *)
(*! | OpMSize => ≪ TRUE , Lab2 , BOT ≫ *)
(*!! OpMSize_3 *)
(*! | OpMSize => ≪ TRUE , Lab2 , LabPC ≫ *)
(*!! OpMSize_4 *)
(*! | OpMSize => ≪ TRUE , Lab2 , Lab1 ≫ *)

(* ---"OpMov"--- *)

(*! *)
| OpMov => ≪ TRUE , Lab1 , LabPC ≫
(*!! OpMov_1 *)
(*! | OpMov => ≪ TRUE , BOT , LabPC ≫ *)
(*!! OpMov_2 *)
(*! | OpMov => ≪ TRUE , Lab1 , BOT ≫ *)
end.

(* Short for a label l to be low/high compared to an observability label obs *)
Notation isLow l obs := (flows l obs).
Notation isHigh l obs := (negb (isLow l obs)).

(** memory frame pointers. *)
Notation mframe := block.

(* values *)
Inductive Pointer : Type :=
  | Ptr (fp:mframe) (i:Z).

Inductive Value : Type :=
  | Vint  (n:Z)
  | Vptr  (p:Pointer)
  | Vlab  (l:Label).

Definition val_eq (v1 v2 : Value) : bool :=
  match v1, v2 with
    | Vint  i1, Vint i2  => i1 == i2
    | Vlab  l1, Vlab l2  => l1 == l2
    | Vptr (Ptr mf1 i1), Vptr (Ptr mf2 i2) => (mf1 == mf2) && (i1 == i2)
    | _, _ => false
  end.

Lemma val_eqP : Equality.axiom val_eq.
Proof.
move=> v1 v2; apply/(iffP idP).
case: v1 => v1; case: v2 => v2 //=.
+ by move/eqP ->.
+ by case: v1.
+ case: v1 => fp1 i1; case: v2 => fp2 i2.
  by case/andP=> [/eqP -> /eqP ->].
+ by case: v1.
+ by move/eqP->.
+ move->; rewrite /val_eq.
  case: v2 => // [[fp2 i2]].
  by apply/andP; split=> //.
Qed.

Definition val_eqMixin := EqMixin val_eqP.
Canonical val_eqType := EqType _ val_eqMixin.

Inductive Atom : Type :=
 | Atm (v:Value) (l:Label).

Infix "@" := Atm (no associativity, at level 50).

Definition eqAtom (a1 a2 : Atom) :=
  match a1, a2 with
  | v1@l1, v2@l2 => (v1 == v2) && (l1 == l2)
  end.

Lemma eqAtomP : Equality.axiom eqAtom.
Proof.
move=> [xv xl] [yv yl] /=.
by apply/(iffP andP)=> [[/eqP -> /eqP ->]|[-> ->]].
Qed.

Canonical Atom_eqMixin := EqMixin eqAtomP.
Canonical Atom_eqType := Eval hnf in EqType Atom Atom_eqMixin.

Inductive Ptr_atom : Type :=
 | PAtm (i:Z) (l:Label).

Definition pc_eq (pc1 pc2 : Ptr_atom) : bool :=
  match pc1, pc2 with
  | PAtm i1 l1, PAtm i2 l2 => (eqtype.eq_op i1 i2 && (eqtype.eq_op l1 l2))%bool
  end.

Definition reg_eq_dec : forall r1 r2 : regId,
  {r1 = r2} + {r1 <> r2}.
Proof. apply Z.eq_dec. Defined.

Hint Resolve reg_eq_dec.

Definition bin_op_eq_dec : forall b1 b2 : BinOpT,
  {b1 = b2} + {b1 <> b2}.
Proof. decide equality. Defined.

Hint Resolve bin_op_eq_dec.

Definition instr_eq_dec : forall i1 i2 : @Instr Label,
  {i1 = i2} + {i1 <> i2}.
Proof. decide equality. apply label_dec. Defined.

Definition instr_eq i1 i2 := if instr_eq_dec i1 i2 then true else false.

Definition imem := list (@Instr Label).

Definition instr_lookup (m:imem) (pc:Ptr_atom) : option (@Instr Label) :=
  let '(PAtm i _) := pc in
  nth_error_Z m i.
Notation "m `[ pc ]" := (instr_lookup m pc) (at level 20).

Definition add_pc (pc:Ptr_atom) (n:Z) : Ptr_atom :=
  let '(PAtm i l) := pc in
  PAtm (Zplus i n) l.
Infix "+" := add_pc.

Definition pc_lab (pc:Ptr_atom) : Label :=
  let '(PAtm _ l) := pc in l.
Notation "'∂' pc" := (pc_lab pc) (at level 0).

Definition atom_lab (a : Atom) : Label :=
  let '(Atm _ l) := a in l.

(* Registers *)
Definition register := Atom.
Definition regSet := list register.

(* Stack *)
Inductive StackFrame := SF : Ptr_atom -> regSet -> regId -> Label -> StackFrame.

Definition sf_return_addr (sf : StackFrame) : Ptr_atom :=
  let '(SF x _ _ _) := sf in x.

Definition sf_saved_regs (sf : StackFrame) : regSet :=
  let '(SF _ x _ _) := sf in x.

Definition sf_result_reg (sf : StackFrame) : regId :=
  let '(SF _ _ x _) := sf in x.

Definition sf_result_lab (sf : StackFrame) : Label :=
  let '(SF _ _ _ x) := sf in x.

Inductive Stack : Type := ST : list StackFrame -> Stack.
Definition unStack s := let 'ST xs := s in xs.

Class Join (t :Type) := {
  join_label: t -> Label -> t
}.
Notation "x ∪ y" := (join_label x y) (right associativity, at level 55).

Global Instance JoinLabel : Join Label := { join_label := join }.

Definition atom_join (a:Atom) (l':Label) : Atom :=
  match a with
    | Atm v l => Atm v (join l l')
  end.

Definition ptr_atom_join (pc:Ptr_atom) (l':Label) : Ptr_atom :=
  let '(PAtm i l) := pc in PAtm i (join_label l l').

Global Instance JoinAtom : Join Atom := { join_label := atom_join }.
Global Instance JoinPtrAtom : Join Ptr_atom := { join_label := ptr_atom_join }.

Ltac try_split_congruence :=
  try solve [left; congruence | right; congruence].

Definition val_eq_val (v1 v2 : Value) : Value :=
  Vint (if val_eq v1 v2 then 1 else 0)%Z.

Definition eval_binop (b : BinOpT) (v1 v2 : Value) : option Value :=
  match b, v1, v2 with
    | BAdd,     Vint z1, Vint z2 => Some (Vint (z1 + z2)%Z)
    | BMult,    Vint z1, Vint z2 => Some (Vint (z1 * z2)%Z)
    | BFlowsTo, Vlab l1, Vlab l2 => Some (Vint (flows_to l1 l2))
    | BJoin,    Vlab l1, Vlab l2 => Some (Vlab (l1 ∪ l2))
    | BEq,      v1     , v2      => Some (val_eq_val v1 v2)
    | _ ,       _ ,      _       => None
  end.

Definition memory := mem Atom.
(* Specialize the Memory frame declaration *)
Definition frame := memframe Atom.

Canonical frame_eqType :=
  Eval hnf in EqType frame (memframe_eqMixin [eqType of Atom]). 

Definition alloc (size:Z) (lab stamp:Label) (a:Atom) (m:memory)
: option (mframe * memory) :=
  match zreplicate size a with
    | Some fr => Some (alloc m stamp (Fr lab fr))
    | _ => None
  end.

Definition load (m : memory) (p : Pointer) : option Atom :=
  let '(Ptr f addr) := p in
  match get_memframe m f with
    | None => None
    | Some (Fr _ fr) => nth_error_Z fr addr
  end.

Definition store (m : memory) (p : Pointer) (a:Atom)
: option (memory) :=
  let '(Ptr f addr) := p in
  match get_memframe m f with
    | None => None
    | Some (Fr lab data) =>
      match update_list_Z data addr a with
        | None => None
        | Some data' => (upd_memframe m f (Fr lab data'))
      end
  end.

Definition msize (m:memory) (p:Pointer) : option nat :=
  let (fp,i) := p in
  match get_memframe m fp with
    | Some (Fr _ data) => Some (length data)
    | _ => None
  end.

Definition mlab (m:memory) (p:Pointer) : option Label :=
  let (fp,i) := p in
  match get_memframe m fp with
    | Some (Fr l _) => Some l
    | _ => None
  end.

Lemma load_alloc : forall size stamp label a m m' mf,
    alloc size stamp label a m = Some (mf, m') ->
    forall mf' ofs',
      load m' (Ptr mf' ofs') =
        if mf == mf' then
          if Z_le_dec 0 ofs' then
            if Z_lt_dec ofs' size then Some a else None
          else None
        else load m (Ptr mf' ofs').
Proof.
  unfold alloc, load; intros.
  destruct (zreplicate size a) eqn:Ez; try congruence; inv H.
  rewrite (alloc_get_memframe H1).
  case: (mf =P mf')=> ? //=; simpl in *.
  subst.
  simpl.
  eapply nth_error_Z_zreplicate; eauto.
Qed.

Lemma load_store : forall {m m'} {b ofs a},
    store m (Ptr b ofs) a = Some m' ->
    forall b' ofs',
      load m' (Ptr b' ofs') =
      if b == b' then
        if ofs == ofs' then Some a else load m (Ptr b' ofs')
      else load m (Ptr b' ofs').
Proof.
  unfold store, load; intros.
  destruct (get_memframe m b) eqn:E1; try congruence.
  destruct m0 as [lab l].
  destruct (update_list_Z l ofs a) eqn:E2; try congruence.
  rewrite (get_upd_memframe H).
  have [e|neb //] := (b =P b'); simpl in *.
  subst b'.
  have [?|?] := eqP.
  + subst ofs'.
    eapply update_list_Z_spec; eauto.
  + rewrite E1.
    symmetry.
    eapply update_list_Z_spec2; eauto.
Qed.

Lemma load_store_old : forall {m m':memory} {b ofs a},
    store m (Ptr b ofs) a = Some m' ->
    forall b' ofs',
      (b',ofs') <> (b,ofs) ->
      load m' (Ptr b' ofs') = load m (Ptr b' ofs').
Proof.
  intros.
  rewrite (load_store H).
  have [?|//] := (b =P b'); subst b'.
  have [?|//] := (ofs =P _); subst ofs'.
  congruence.
Qed.

Lemma load_store_new : forall {m m':memory} {b ofs a},
    store m (Ptr b ofs) a = Some m' ->
    load m' (Ptr b ofs) = Some a.
Proof. by move=> ????? H; rewrite (load_store H) !eqxx.  Qed.

Lemma load_some_store_some : forall {m:memory} {b ofs a},
    load m (Ptr b ofs) = Some a ->
    forall a':Atom,
      exists m', store m (Ptr b ofs) a' = Some m'.
Proof.
  unfold load, store; intros.
  destruct (get_memframe m b) eqn:E; try congruence.
  destruct m0 eqn:?. (* I don't like this *)
  exploit nth_error_Z_valid; eauto.
  destruct 1.
  destruct (@update_list_Z_Some _ a' l ofs); auto.
  rewrite H2.
  eapply upd_get_memframe; eauto.
Qed.

Lemma get_memframe_store_neq :
  forall (m : memory ) b b' off a m'
         (STORE : store m (Ptr b off) a = Some m')
         (NEQ : b' <> b),
    get_memframe m' b' = get_memframe m b'.
Proof.
  unfold store.
  intros.
  destruct (get_memframe m b) as [f|] eqn:FRAME; try congruence.
  destruct f as [lab l] eqn:?.
  destruct (update_list_Z l off a) as [l'|] eqn:NEWFRAME; try congruence.
  eapply get_memframe_upd_memframe_neq; eauto.
Qed.

Lemma alloc_get_memframe_eq :
  forall s (mem : memory) f b mem',
    Memory.alloc mem s f = (b, mem') ->
    get_memframe mem' b = Some f.
Proof.
  intros.
  erewrite alloc_get_memframe; eauto.
  by rewrite eqxx.
Qed.

Lemma alloc_get_memframe_neq :
  forall s (mem : memory) f b b' mem',
    Memory.alloc mem s f = (b, mem') ->
    b <> b' ->
    get_memframe mem' b' = get_memframe mem b'.
Proof.
  intros.
  erewrite alloc_get_memframe; eauto.
  have [?|?] := (b =P b'); simpl in *; congruence.
Qed.

Definition extends (m1 m2 : memory) : Prop :=
  forall b fr, get_memframe m1 b = Some fr -> get_memframe m2 b = Some fr.

Lemma extends_refl : forall (m : memory), extends m m.
Proof. unfold extends. auto. Qed.

Lemma extends_trans : forall (m1 m2 m3 : memory),
  extends m1 m2 -> extends m2 m3 -> extends m1 m3.
Proof. unfold extends. auto. Qed.

Lemma extends_load (m1 m2 : memory) b off a :
  forall (EXT : extends m1 m2)
         (DEF : load m1 (Ptr b off) = Some a),
    load m2 (Ptr b off) = Some a.
Proof.
  intros.
  unfold load in *.
  destruct (get_memframe m1 b) as [fr|] eqn:FRAME; inv DEF.
  erewrite EXT; eauto.
Qed.

(* Machine SStates *)

Inductive SState := St : imem -> memory -> Stack -> regSet -> Ptr_atom -> SState.

Definition st_imem (st : SState) : imem :=
  let '(St x _ _ _ _) := st in x.

Definition st_mem (st : SState) : memory :=
  let '(St _ x _ _ _) := st in x.

Definition st_stack (st : SState) : Stack :=
  let '(St _ _ x _ _) := st in x.

Definition st_regs (st : SState) : regSet :=
  let '(St _ _ _ x _) := st in x.

Definition st_pc (st : SState) : Ptr_atom :=
  let '(St _ _ _ _ x) := st in x.

Definition registerUpdate (rs : regSet) (r : regId) (a : Atom) :=
  update_list_Z rs r a.
Definition registerContent (rs : regSet) (r : regId) :=
  nth_error_Z rs r.

Definition run_tmr (t : table) (op: OpCode)
  (labs:Vector.t Label (labelCount op)) (pc: Label)
   : option (option Label * Label) :=
  let r := t op in
  apply_rule r labs pc.

(** Declarative semantics *)

Local Open Scope Z_scope.
(* CH: we only need to instantiate this for the default table,
       so we could even consider baking it in *)

Inductive step (t : table) : SState -> SState -> Prop :=
 | step_lab: forall im μ σ v K pc r r' r1 r2 j LPC rl rpcl
     (PC: pc = PAtm j LPC)
     (CODE: im`[pc] = Some (Lab r1 r2))
     (REG1: registerContent r r1 = Some (v @ K))
     (TMU: run_tmr t OpLab <||> LPC = Some (Some rl, rpcl))
     (UPD: registerUpdate r r2 (Vlab K @ rl) = Some r'),
     step t
          (St im μ σ r pc)
          (St im μ σ r' (PAtm (j+1) rpcl))
 | step_pclab: forall im μ σ pc r r' r1 j LPC rl rpcl
     (PC: pc = PAtm j LPC)
     (CODE: im`[pc] = Some (PcLab r1))
     (TMU: run_tmr t OpPcLab <||> LPC = Some (Some rl, rpcl))
     (RES : registerUpdate r r1 (Vlab (∂ pc) @ rl) = Some r'),
     step t
       (St im μ σ r pc)
       (St im μ σ r' (PAtm (j+1) rpcl))
 | step_mlab: forall im μ σ pc r r1 r2 p K C j LPC rl r' rpcl
     (PC: pc = PAtm j LPC)
     (CODE: im`[pc] = Some (MLab r1 r2))
     (OLD : mlab μ p = Some C)
     (OP1 : registerContent r r1 = Some (Vptr p @ K))
     (TMU : run_tmr t OpMLab <|K; C|> LPC = Some (Some rl, rpcl))
     (RES : registerUpdate r r2 (Vlab C @ rl) = Some r'),
     step t
       (St im μ σ r pc)
       (St im μ σ r' (PAtm (Z.succ j) rpcl))
 | step_putlab: forall im μ σ pc r r' r1 j LPC rl rpcl l
     (PC: pc = PAtm j LPC)
     (CODE: im`[pc] = Some (PutLab l r1))
     (TMU : run_tmr t OpPutLab <||> LPC = Some (Some rl, rpcl))
     (RES : registerUpdate r r1 (Vlab l @ rl) = Some r'),
     step t
       (St im μ σ r pc)
       (St im μ σ r' (PAtm (j+1) rpcl))
 | step_bcall: forall im μ σ pc B K r r1 r2 r3 j La addr Lpc rl rpcl
     (PC: pc = PAtm j Lpc)
     (CODE: im`[pc] = Some (BCall r1 r2 r3))
     (OP1 : registerContent r r1 = Some (Vint addr @ La))
     (OP2 : registerContent r r2 = Some (Vlab B @ K))
     (TMU : run_tmr t OpBCall <|La; K|> Lpc = Some (Some rl, rpcl)),
     step t
       (St im μ σ r pc)
       (St im μ (ST (SF (PAtm (j+1) rl) r r3 B :: (unStack σ))) r (PAtm addr rpcl))
 | step_bret: forall im μ σ pc a r r' r'' r1 R pc' B j j' LPC LPC' rl rpcl
     (PC: pc  = PAtm j  LPC)
     (PC': pc' = PAtm j' LPC')
     (CODE: im`[pc] = Some BRet)
     (STAYS : registerContent r r1 = Some (a @ R))
     (TMU : run_tmr t OpBRet <|R; B; LPC'|> LPC = Some (Some rl, rpcl))
     (RES : registerUpdate r' r1 (a @ rl) = Some r''),
     step t
       (St im μ (ST (SF pc' r' r1 B :: σ)) r pc)
       (St im μ (ST σ) r'' (PAtm j' rpcl))
 | step_alloc: forall im μ μ' σ pc r r' r1 r2 r3 i K Ll K' rl rpcl j LPC dfp
     (PC: pc = PAtm j LPC)
     (CODE: im`[pc] = Some (Alloc r1 r2 r3))
     (OP1 : registerContent r r1 = Some (Vint i @ K))
     (OP2 : registerContent r r2 = Some (Vlab Ll @ K'))
     (TMU : run_tmr t OpAlloc <|K; K'; Ll|> LPC = Some (Some rl, rpcl))
     (ALLOC: alloc i Ll (K ∪ K' ∪ LPC) (Vint 0 @ ⊥) μ = Some (dfp, μ'))
     (* LL: Using label Ll directly as the label of the mframe,
        also using rl for both the pointer label and the stamp *)
     (RES : registerUpdate r r3 (Vptr (Ptr dfp 0) @ rl) = Some r'),
     step t
       (St im μ σ r pc)
       (St im μ' σ r' (PAtm (j+1) rpcl))
 | step_load: forall im μ σ pc C p K r r' r1 r2 j LPC v Ll rl rpcl
     (PC  : pc = PAtm j LPC)
     (CODE: im`[pc] = Some (Load r1 r2))
     (OP1 : registerContent r r1 = Some (Vptr p @ K))
     (READ: load μ p = Some (v @ Ll))
     (MLAB: mlab μ p = Some C)
     (TMU : run_tmr t OpLoad <|K; C; Ll|> LPC = Some (Some rl, rpcl))
     (RES : registerUpdate r r2 (v @ rl) = Some r'),
     step t
       (St im μ σ r pc)
       (St im μ σ r' (PAtm (j+1) rpcl))
 | step_store: forall im μ σ pc v p μ' r r1 r2 j LPC rpcl rl lp lf lv
     (PC  : pc = PAtm j LPC)
     (CODE: im`[pc] = Some (Store r1 r2))
     (OP1 : registerContent r r1 = Some (Vptr p @ lp))
     (OP2 : registerContent r r2 = Some (v @ lv))
     (MLAB: mlab μ p = Some lf)
     (TMU : run_tmr t OpStore <|lp; lf; lv|> LPC = Some (Some rl, rpcl))
     (WRITE: store μ p (v @ rl) = Some μ'),
     step t
       (St im μ σ r pc)
       (St im μ' σ r (PAtm (j+1) rpcl))
 | step_write: forall im μ σ pc v p μ' r r1 r2 j LPC rpcl rl v' lp lv lv' lf
     (PC  : pc = PAtm j LPC)
     (CODE: im`[pc] = Some (Write r1 r2))
     (OP1 : registerContent r r1 = Some (Vptr p @ lp))
     (OP2 : registerContent r r2 = Some (v @ lv))
     (READ: load μ p = Some (v' @ lv'))
     (MLAB: mlab μ p = Some lf)
     (TMU : run_tmr t OpWrite <|lp;lf;lv;lv'|> LPC = Some (Some rl, rpcl))
     (WRITE: store μ p (v @ rl) = Some μ'),
     step t
       (St im μ σ r pc)
       (St im μ' σ r (PAtm (j+1) rpcl))
 | step_jump: forall im μ σ pc addr Ll r r1 j LPC rpcl
     (PC: pc = PAtm j LPC)
     (CODE: im`[pc] = Some (Jump r1))
     (OP1 : registerContent r r1 = Some (Vint addr @ Ll))
     (TMU: run_tmr t OpJump <|Ll|> LPC = Some (None, rpcl)),
     step t
       (St im μ σ r pc)
       (St im μ σ r (PAtm addr rpcl))
 | step_bnz: forall im μ σ pc n m K r r1 j LPC rpcl
     (PC: pc = PAtm j LPC)
     (CODE: im`[pc] = Some (BNZ n r1))
     (OP1 : registerContent r r1 = Some (Vint m @ K))
     (TMU: run_tmr t OpBNZ <|K|> LPC = Some (None, rpcl)),
     step t
       (St im μ σ r pc)
       (St im μ σ r (PAtm (if m == 0 then j + 1 else j + n) rpcl))
 | step_psetoff: forall im μ σ pc fp' j K1 n K2 r r' r1 r2 r3 j' LPC rl rpcl
     (PC: pc = PAtm j LPC)
     (CODE: im`[pc] = Some (PSetOff r1 r2 r3))
     (OP1 : registerContent r r1 = Some (Vptr (Ptr fp' j') @ K1))
     (OP2 : registerContent r r2 = Some (Vint n @ K2))
     (TMU: run_tmr t OpPSetOff <|K1; K2|> LPC = Some (Some rl, rpcl))
     (RES : registerUpdate r r3 (Vptr (Ptr fp' n) @ rl) = Some r'),
     step t
       (St im μ σ r pc)
       (St im μ σ r' (PAtm (j + 1) rpcl))
 | step_put: forall im μ σ pc x r r' r1 j LPC rl rpcl
     (PC: pc = PAtm j LPC)
     (CODE: im`[pc] = Some (Put x r1))
     (TMU : run_tmr t OpPut <||> LPC = Some (Some rl, rpcl))
     (OP1 : registerUpdate r r1 (Vint x @ rl) = Some r'),
     step t
       (St im μ σ r pc)
       (St im μ σ r' (PAtm (j+1) rpcl))
 | step_binop: forall im μ σ pc o v1 L1 v2 L2 v r r1 r2 r3 r' j LPC rl rpcl
     (PC: pc = PAtm j LPC)
     (CODE: im`[pc] = Some (BinOp o r1 r2 r3))
     (OP1 : registerContent r r1 = Some (v1 @ L1))
     (OP2 : registerContent r r2 = Some (v2 @ L2))
     (TMU : run_tmr t OpBinOp <|L1; L2|> LPC = Some (Some rl, rpcl))
     (BINOP: eval_binop o v1 v2 = Some v)
     (RES : registerUpdate r r3 (v @ rl) = Some r'),
     step t
       (St im μ σ r pc)
       (St im μ σ r' (PAtm (j+1) rpcl))
 | step_nop: forall im μ σ pc r j LPC rpcl
     (PC: pc = PAtm j LPC)
     (CODE: im`[pc] = Some Nop)
     (TMU : run_tmr t OpNop <||> LPC = Some (None, rpcl)),
     step t
       (St im μ σ r pc)
       (St im μ σ r (PAtm (j+1) rpcl))
 | step_msize: forall im μ σ pc p K C r r' r1 r2 j LPC rl rpcl n
     (PC: pc = PAtm j LPC)
     (CODE: im`[pc] = Some (MSize r1 r2))
     (OP1 : registerContent r r1 = Some (Vptr p @ K))
     (MLAB: mlab μ p = Some C)
     (TMU: run_tmr t OpMSize <|K; C|> LPC = Some (Some rl, rpcl))
     (MSIZE: msize μ p = Some n)
     (RES : registerUpdate r r2 (Vint (Z.of_nat n) @ rl) = Some r'),
     step t
       (St im μ σ r pc)
       (St im μ σ r' (PAtm (j+1) rpcl))
 | step_pgetoff: forall im μ σ pc fp' j K r r' r1 r2 j' LPC rl rpcl
     (PC: pc = PAtm j LPC)
     (CODE: im`[pc] = Some (PGetOff r1 r2))
     (OP1 : registerContent r r1 = Some (Vptr (Ptr fp' j') @ K))
     (TMU: run_tmr t OpPGetOff <|K|> LPC = Some (Some rl, rpcl))
     (RES : registerUpdate r r2 (Vint j' @ rl) = Some r'),
     step t
       (St im μ σ r pc)
       (St im μ σ r' (PAtm (j+1) rpcl))
 | step_mov: forall im μ σ v K pc r r' r1 r2 j LPC rl rpcl
     (PC: pc = PAtm j LPC)
     (CODE: im`[pc] = Some (Mov r1 r2))
     (REG1: registerContent r r1 = Some (v @ K))
     (TMU: run_tmr t OpMov <|K|> LPC = Some (Some rl, rpcl))
     (UPD: registerUpdate r r2 (v @ rl) = Some r'),
     step t
          (St im μ σ r pc)
          (St im μ σ r' (PAtm (j+1) rpcl)).

(** * Executable semantics *)

Definition SState_instr_lookup (st:SState) : option (@Instr Label) :=
  (st_imem st)`[st_pc st].

Definition fstep t (st:SState) : option SState :=
  do instr <- SState_instr_lookup st;
  let '(St im μ σ r pc) := st in
  let '(PAtm j LPC) := pc in
  match instr with
    | Lab r1 r2 =>
      match registerContent r r1 with
        | Some (_ @ K) =>
          match run_tmr t OpLab <||> LPC with
            | Some (Some rl, rpcl) =>
              do r' <- registerUpdate r r2 (Vlab K @ rl);
                Some (St im μ σ r' (PAtm (j+1) rpcl))
            | _ => None
          end
        | None => None
      end
    | PcLab r1 =>
      match run_tmr t OpPcLab <||> LPC with
        | Some (Some rl, rpcl) =>
          do r' <- registerUpdate r r1 (Vlab (∂ pc) @ rl);
            Some (St im μ σ r' (PAtm (j+1) rpcl))
        | _ => None
      end
    | MLab r1 r2 =>
      match registerContent r r1 with
        | Some (Vptr p @ K) =>
            do C <- mlab μ p;
            match run_tmr t OpMLab <|K; C|> LPC with
              | Some (Some rl, rpcl) =>
                do r' <- registerUpdate r r2 (Vlab C @ rl);
                Some (St im μ σ r' (PAtm (j+1) rpcl))
              | _ => None
            end
        | _ => None
      end
    | PutLab l r1 =>
      match run_tmr t OpPutLab <||> LPC with
        | Some (Some rl, rpcl) =>
          do r' <- registerUpdate r r1 (Vlab l @ rl);
          Some (St im μ σ r' (PAtm (j+1) rpcl))
            | _ => None
          end
    | BCall r1 r2 r3 =>
      match registerContent r r1, registerContent r r2 with
        | Some (Vint addr @ Ll), Some (Vlab B @ K) =>
          match run_tmr t OpBCall <|Ll; K|> LPC with
            | Some (Some rl, rpcl) =>
              Some (St im μ (ST (SF (PAtm (j+1) rl) r r3 B :: (unStack σ))) r
                       (PAtm addr rpcl))
            | _ => None
          end
        | _, _ => None
      end
    | BRet =>
      match σ with
        | ST (SF (PAtm jp' LPC') savedRegs r1 B :: σ') =>
          do r1Cont <- registerContent r r1;
          let '(a @ R) := r1Cont in
          match run_tmr t OpBRet <|R; B; LPC'|> LPC with
            | Some (Some rl, rpcl) =>
              do r' <- registerUpdate savedRegs r1 (a @ rl);
              Some (St im μ (ST σ') r' (PAtm jp' rpcl))
            | _ => None
          end
        | _ => None
      end
    | Alloc r1 r2 r3 =>
      match registerContent r r1, registerContent r r2 with
        | Some (Vint i @ K), Some (Vlab Ll @ K') =>
          match run_tmr t OpAlloc <|K; K'; Ll|> LPC with
            | Some (Some rl, rpcl) =>
              let stmp := K ∪ K' ∪ LPC in
                 (* this stamp is just instrumentation;
                    and it doesn't go via the rule table *)
              do alloc_res : (mframe * memory) <- alloc i Ll stmp (Vint 0 @ ⊥) μ;
              let (dfp, μ') := alloc_res in
              do r' <- registerUpdate r r3 (Vptr (Ptr dfp 0) @ rl);
              Some (St im μ' σ r' (PAtm (j+1) rpcl))
            | _ => None
          end
        | _, _ => None
      end
    | Load r1 r2 =>
      match registerContent r r1 with
        | Some (Vptr p @ K) =>
            do a <- load μ p;
            let '(v @ Ll) := a in
            do C <- mlab μ p;
            match run_tmr t OpLoad <|K; C; Ll|> LPC with
              | Some (Some rl (* Ll *), rpcl (* LPC ∪ K ∪ C *)) =>
                do r' <- registerUpdate r r2 (v @ rl);
                Some (St im μ σ r' (PAtm (j+1) (rpcl)))
              | _ => None
            end
        | _ => None
      end
    | Store r1 r2 =>
      match registerContent r r1, registerContent r r2 with
        | Some (Vptr p @ lp), Some (v @ lv) =>
          do lf <- mlab μ p;
          match run_tmr t OpStore <|lp; lf; lv|> LPC with
            (* check: lp ∪ LPC <: lf *)
            | Some (Some rl (* lv *), rpcl (* LPC *)) =>
              do μ' <- store μ p (v @ rl);
              Some (St im μ' σ r (PAtm (j+1) rpcl))
            | _ => None
          end
        | _, _ => None
      end
    | Write r1 r2 =>
      match registerContent r r1, registerContent r r2 with
        | Some (Vptr p @ lp), Some (v @ lv) =>
          do a <- load μ p;
          let '(_ @ lv') := a in
          do lf <- mlab μ p;
          match run_tmr t OpWrite <|lp; lf; lv; lv'|> LPC with
            | Some (Some rl, rpcl) =>
              do μ' <- store μ p (v @ rl);
              Some (St im μ' σ r (PAtm (j+1) rpcl))
            | _ => None
          end
        | _, _ => None
      end
    | Jump r1 =>
      match registerContent r r1 with
        | Some (Vint addr @ Ll) =>
          match run_tmr t OpJump <|Ll|> LPC with
            | Some (None, rpcl) =>
              Some (St im μ σ r (PAtm addr rpcl))
            | _ => None
          end
        | _ => None
      end
    | BNZ n r1 =>
      match registerContent r r1 with
        | Some (Vint m @ K) =>
          match run_tmr t OpBNZ <|K|> LPC with
            | Some (None, rpcl) =>
              let new_pc := (if m == 0 then j+1 else j+n) in
                Some (St im μ σ r (PAtm new_pc rpcl))
            | _ => None
          end
        | _ => None
      end
    | PSetOff r1 r2 r3 =>
      match registerContent r r1, registerContent r r2 with
        | Some (Vptr (Ptr fp' j') @ K1), Some (Vint n @ K2) =>
          match run_tmr t OpPSetOff <|K1; K2|> LPC with
            | Some (Some rl, rpcl) =>
              do r' <- registerUpdate r r3 (Vptr (Ptr fp' n) @ rl);
              Some (    St im μ σ r' (PAtm (j+1) rpcl))
            | _ => None
          end
        | _, _ => None
      end
    | Put x r1 =>
      match run_tmr t OpPut <||> LPC with
        | Some (Some rl, rpcl) =>
          do r' <- registerUpdate r r1 (Vint x @ rl);
            Some (St im μ σ r' (PAtm (j+1) rpcl))
        | _ => None
      end
     | BinOp o r1 r2 r3 =>
       match registerContent r r1, registerContent r r2 with
         | Some (v1 @ L1), Some (v2 @ L2) =>
           match run_tmr t OpBinOp <|L1; L2|> LPC with
             | Some (Some rl, rpcl) =>
               do v <- eval_binop o v1 v2;
               do r' <- registerUpdate r r3 (v @ rl);
               Some (St im μ σ r' (PAtm (j+1) rpcl))
             | _ => None
           end
         | _, _ => None
       end
     | Nop =>
       match run_tmr t OpNop <||> LPC with
         | Some (None, rpcl) =>
           Some (St im μ σ r (PAtm (j+1) rpcl))
         | _ => None
       end
    | MSize r1 r2 =>
      match registerContent r r1 with
        | Some (Vptr p @ K) =>
            do C <- mlab μ p;
            match run_tmr t OpMSize <|K; C|> LPC with
              | Some (Some rl, rpcl) =>
                do n <- msize μ p;
                do r' <- registerUpdate r r2 (Vint (Z.of_nat n) @ rl);
                Some (St im μ σ r' (PAtm (j+1) rpcl))
              | _ => None
            end
        | _ => None
      end
    | PGetOff r1 r2 =>
      match registerContent r r1 with
        | Some (Vptr (Ptr fp' j') @ K) =>
          match run_tmr t OpPGetOff <|K|> LPC with
            | Some (Some rl, rpcl) =>
              do r' <- registerUpdate r r2 (Vint j' @ rl);
              Some (St im μ σ r' (PAtm (j+1) rpcl))
            | _ => None
          end
        | _ => None
      end
    | Mov r1 r2 =>
      match registerContent r r1 with
        | Some (v @ K) =>
          match run_tmr t OpMov <|K|> LPC with
            | Some (Some rl, rpcl) =>
              do r' <- registerUpdate r r2 (v @ rl);
                Some (St im μ σ r' (PAtm (j+1) rpcl))
            | _ => None
          end
        | None => None
      end
    | Halt => None
  end.

Ltac fstep_inv :=
  simpl;
  match goal with
  | |- (do _ <- ?x; _) = Some _ -> _ =>
    let er := fresh "er" in
    destruct x as [?|] eqn:er; try done
  | |- Some ?v = Some ?v' -> _ =>
    move=> [?]; subst
  | |- match ?v with _ => _ end = Some _ -> _ =>
    let em := fresh "em" in
    destruct v eqn:em; try done
  | |- None = Some _ -> _ => done
  end.

Ltac step_rewrite :=
  simpl;
  match goal with
  | H : ?x = Some _ |- context[do _ <- ?x; _] =>
    rewrite H
  | H : ?v = _ |- context[match ?v with _ => _ end] => rewrite H
  end;
  simpl.

Lemma fstepP t st st' : fstep t st = Some st' <-> step t st st'.
Proof.
rewrite /fstep /= /SState_instr_lookup /=; split.
  case: st=> [im m st rs [pc pcl]] /=;
  case get_instr: nth_error_Z => [instr|] //=.
Admitted. 
(*
  destruct instr; repeat fstep_inv;
  econstructor; (solve [simpl; eauto]).
by case; intros; subst; simpl in *;
repeat step_rewrite.
Qed.
*)

Fixpoint fstepN t (n : nat) (s : SState) : list SState :=
  match n with
    | O => (s :: nil)
    | S n' =>
      match fstep t s with
        | Some s' =>
          let res := fstepN t n' s' in
          (s :: res)
        | None => (s :: nil)
      end
  end%list.

Lemma pc_eqP : Equality.axiom pc_eq.
Proof.
move=> [xv xl] [yv yl] /=.
apply/(iffP idP)=> [/andP [] /eqP -> /eqP ->|[-> ->]] //.
by rewrite !eqxx.
Qed.

Definition pc_eqMixin := EqMixin pc_eqP.
Canonical pc_eqType := EqType _ pc_eqMixin.

