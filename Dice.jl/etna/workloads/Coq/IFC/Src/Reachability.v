Require Import ZArith.

From mathcomp Require Import ssreflect ssrfun ssrbool eqtype ssrnat seq choice fintype.

Require Import TestingCommon.

Import LabelEqType.

Definition is_low_pointer (obs : Label) (a : Atom) : bool :=
  match a with
    | Vptr p @ l => isLow l obs
    | _ => false
  end.

Definition extract_mframe (a : Atom) : option mframe :=
  match a with
    | Vptr (Ptr fp _) @ _ => Some fp
    | _ => None
  end.

Definition elem {A : Type} (eq_dec : forall (x y : A), {x = y} + {x <> y})
           (x : A) (l : list A) : bool :=
  has (fun y => if eq_dec x y then true else false) l.

(* This unions two sets while removing duplicates *)
Fixpoint nub_by_aux (A : eqType) (l acc : list A) : list A :=
  match l with
    | [::] => acc
    | h::t =>
      if h \in acc
      then nub_by_aux A t acc
      else nub_by_aux A t (h::acc)
  end.

(* This removes duplicates from a list *)
Definition nub_by {A : eqType} (l : list A) := nub_by_aux A l [::].

Definition get_mframes_from_atoms (obs : Label) (atoms : list Atom)
  : list mframe :=
  nub_by (pmap extract_mframe (filter (is_low_pointer obs) atoms)).

Fixpoint get_root_set_stack (obs : Label)
         (acc : list mframe) (s : list StackFrame) : list mframe :=
  match s with
    | nil => acc
    | (SF pc rs _ _) :: s' =>
      let new_mframes :=
          if isLow ∂pc obs then get_mframes_from_atoms obs rs
          else [::] in
      let acc' := nub_by_aux _ new_mframes acc in
      get_root_set_stack obs acc' s'
  end.

Definition get_root_set (obs : Label) (st : SState) : list mframe :=
  let '(St _ _ s r pc) := st in
  let init_root_set :=
      if isLow ∂pc obs then get_mframes_from_atoms obs r
      else [::] in
  get_root_set_stack obs init_root_set (unStack s).

Function reachable_from_root_set (obs : Label) (st : SState)
         (visited worklist : list mframe)
  {measure (fun w => 0) worklist} (* TODO: prove termination?
     CH: Yes, but this measure is completely bogus; a good measure would be the
         length (all frames / (visited / workist)), or something like that *)
  : list mframe :=
  match worklist with
    | [::] => visited
    | h::t =>
      if h \in visited then
        reachable_from_root_set obs st visited t
      else
        match get_memframe (st_mem st) h with
          | Some (Fr l atoms) =>
            let newCands :=
                if isLow l obs then
                  get_mframes_from_atoms obs atoms
                else [::] in
            let worklist' := nub_by_aux _ newCands t in
            reachable_from_root_set obs st (h :: visited) worklist'
          | _ => reachable_from_root_set obs st (h :: visited) t
        end
  end.
Proof.
Admitted.

Definition reachable (obs : Label) (st : SState) : list mframe :=
  let root_set := get_root_set obs st in
  reachable_from_root_set obs st [::] root_set.

Definition well_formed_label (st : SState) (l : Label) : bool :=
  let observable := reachable l st in
  all (fun mf => let s := Memory.stamp mf in isLow s l) observable.

(* Given a SState and a stamp configuration, make sure everything is ok *)
(* LL: This also suggests a way of generating stamps! Namely, get
   the meet of all the labels where a frame is reachable *)
Definition well_formed (st : SState) : bool :=
  all (well_formed_label st) all_labels.

(* Computes the meet of a list of labels. Must be provided with top as the
   initial accumulator *)
Definition list_meet (acc : Label) (ls : list Label) :=
  foldl meet acc ls.
