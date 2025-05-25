
From QuickChick Require Import QuickChick. Import QcNotation.
From Coq Require Import Bool ZArith List. Import ListNotations.
From BST Require Import Impl.

Fixpoint keys (t: Tree): list nat :=
  match t with
  | E => nil
  | T l k v r =>
    let lk := keys l in
    let rk := keys r in
    [k] ++ lk ++ rk
  end.


Fixpoint all {A: Type} (f: A -> bool) (l: list A): bool :=
  match l with
  | nil => true
  | (x::xs) =>
      f x && all f xs
  end
  .


Local Open Scope nat_scope.

Definition Nat_gtb (n1 n2: nat) : bool :=
  negb (n1 <=? n2).

Fixpoint isBST (t: Tree): bool:=
  match t with
  | E => true
  | (T l k _ r) =>
    isBST l
      && isBST r
      && all (Nat_gtb k) (keys l)
      && all (Nat.ltb k) (keys r)
  end.




Fixpoint toList (t: Tree): list (nat * nat) :=
  match t with
  | E => nil
  | T l k v r =>
    toList l ++ [(k, v)] ++ toList r
  end.

(* -- Validity properties. *)

Definition prop_InsertValid (t: Tree) (k: nat) (v: nat) :=
  isBST t -=> Some(isBST (insert k v t)).

Definition prop_DeleteValid (t: Tree) (k: nat) :=
  isBST t -=> Some(isBST (delete k t)).


Definition prop_UnionValid (t1: Tree) (t2: Tree) :=
  (isBST t1 && isBST t2) -=> (isBST (union t1 t2)).

(* ---------- *)


(* -- Postcondition properties. *)

Definition prop_InsertPost (t: Tree) (k: nat) (k': nat) (v: nat) :=
  isBST t
    -=> (find k' (insert k v t) ==? if k =? k' then Some v else find k' t).

Definition prop_DeletePost (t: Tree) (k: nat) (k': nat) :=
  isBST t
    -=> (find k' (delete k t) ==? if k =? k' then None else find k' t).

Definition prop_UnionPost (t: Tree) (t': Tree) (k: nat) :=
  isBST t
    -=>
    let lhs := find k (union t t') in
    let rhs := find k t in
    let rhs':= find k t' in
    ((lhs ==? rhs) || (lhs ==? rhs')) .

(* ---------- *)

(* -- Model-based properties. *)

Definition deleteKey  (k: nat) (l: list (nat * nat)): list (nat * nat) :=
  filter (fun x => negb (fst x =? k)) l.

Fixpoint L_insert (kv: nat * nat) (l: list (nat * nat)) : list (nat * nat) :=
  match l with
  | nil => [kv]
  | (k, v)::xs =>
    if fst kv =? k then (fst kv, snd kv)::xs
    else if fst kv <? k then (fst kv, snd kv)::l
    else (k, v)::(L_insert kv xs)
  end.


Fixpoint sorted (l: list (nat * nat)): bool :=
  match l with
  | nil => true
  | (k, v)::l' =>
    match l' with
    | nil => true
    | (k', v')::l'' =>
      (k <? k') && sorted l'
    end
  end.


Definition prop_InsertModel (t: Tree) (k: nat) (v: nat) :=
  isBST t
    -=> (toList (insert k v t) ==? L_insert (k, v) (deleteKey k (toList t))).


Definition prop_DeleteModel (t: Tree) (k: nat) :=
  isBST t
    -=> Some(toList (delete k t) ==? deleteKey k (toList t)).


Fixpoint L_sort (l: list (nat * nat)): list (nat * nat) :=
  match l with
  | nil => nil
  | (k, v)::l' =>
    L_insert (k, v) (L_sort l')
  end.

Definition L_find (k: nat) (l: list (nat * nat)): option nat :=
  match filter (fun x => fst x =? k) l with
  | nil => None
  | (k, v)::l' => Some v
  end.

Fixpoint L_unionBy (f: nat -> nat -> nat) (l1: list (nat * nat)) (l2: list (nat * nat)): list (nat * nat) :=
  match l1 with
  | nil => l2
  | (k, v)::l1' =>
    let l2' := deleteKey k l2 in
    let v' := match L_find k l2 with
              | None => v
              | Some v' => f v v'
              end
    in
    L_insert (k, v') (L_unionBy f l1' l2')
  end.


Definition prop_UnionModel (t: Tree) (t': Tree) :=
  (isBST t && isBST t')
    -=> (toList (union t t') ==? L_sort (L_unionBy (fun x y => x) (toList t) (toList t'))).


(* ---------- *)

Fixpoint tree_eqb (t: Tree) (t': Tree) : bool :=
  toList t ==? toList t'.

Notation "A =|= B" := (tree_eqb A B) (at level 100, right associativity).
(* -- Metamorphic properties. *)

Definition prop_InsertInsert (t: Tree) (k: nat) (k': nat) (v: nat) (v': nat) :=
  isBST t
    -=> (insert k v (insert k' v' t) =|= if k =? k' then insert k v t else insert k' v' (insert k v t)).

Definition prop_InsertDelete (t: Tree) (k: nat) (k': nat) (v: nat) :=
  isBST t
    -=> (insert k v (delete k' t) =|= if k =? k' then insert k v t else delete k' (insert k v t)).

Definition prop_InsertUnion (t: Tree) (t': Tree) (k: nat) (v: nat) :=
  (isBST t && isBST t')
    -=> (insert k v (union t t') =|= union (insert k v t) t').

Definition prop_DeleteInsert (t: Tree) (k: nat) (k': nat) (v': nat) :=
  isBST t
    -=>
  (delete k (insert k' v' t) =|= if k =? k' then delete k t else insert k' v' (delete k t)).

Definition prop_DeleteDelete (t: Tree) (k: nat) (k': nat) :=
  isBST t
    -=> (delete k (delete k' t) =|= delete k' (delete k t)).

Definition prop_DeleteUnion (t: Tree) (t': Tree) (k: nat) :=
  (isBST t && isBST t')
    -=> Some(delete k (union t t')
    =|= union (delete k t) (delete k t')).

Definition prop_UnionDeleteInsert (t :Tree) (t': Tree) (k: nat) (v: nat) :=
  (isBST t && isBST t')
    -=> Some(union (delete k t) (insert k v t')
    =|= insert k v (union t t')).

Definition prop_UnionUnionIdem (t: Tree) :=
  isBST t
    -=> union t t =|= t.

Definition prop_UnionUnionAssoc (t1: Tree) (t2: Tree) (t3: Tree) :=
  (isBST t1 && isBST t2 && isBST t3)
    -=> (union (union t1 t2) t3 =|= union t1 (union t2 t3)).



(* ---------- *)

Definition sizeBST (t: Tree) : nat :=
  length (toList t).

(* -- Size properties. *)
