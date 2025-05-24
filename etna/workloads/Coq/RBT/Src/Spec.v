
(* -- Based on SmallCheck implementation (based on Okasaki 1999),
-- but in the style of How to Specify It. *)


Require Import ZArith.
From QuickChick Require Import QuickChick.
From ExtLib Require Import Monad.
From ExtLib.Data.Monads Require Import OptionMonad.
Import QcNotation.
Import MonadNotation.
From Coq Require Import List.
Import ListNotations.


Local Open Scope Z_scope.

From RBT Require Import Impl.


Fixpoint isBST (t: Tree) : bool :=
    let fix every (p : Z -> bool) (t: Tree) : bool :=
        match t with
        | E => true
        | (T _ a x _ b) => andb (andb (p x) (every p a)) (every p b)
        end in
    match t with
    | E => true
    | (T _ a x _ b) =>
  (* -- Difference from SC: don't allow repeated keys. *)
        every (Z.gtb x) a && every (Z.ltb x) b && isBST a && isBST b
    end.
    
(* -- "No red node has a red parent." *)
Fixpoint noRedRed (t: Tree) : bool :=
    let fix blackRoot (t: Tree) : bool :=
        match t with
        | (T R _ _ _ _) => false
        | _ => true
        end in
    match t with
    | E => true
    | (T B a _ _ b) => noRedRed a && noRedRed b
    | (T R a _ _ b) => blackRoot a && blackRoot b && noRedRed a && noRedRed b
    end.
    

(* -- "Every path from the root to an empty node contains the same number of black nodes." *)
Definition consistentBlackHeight  (t: Tree) : bool :=
    let fix go (t: Tree) : (bool * Z) :=
        match t with
        | E => (true, 1)
        | T rb a x _ b =>
            let (aBool, aHeight) := go a in
            let (bBool, bHeight) := go b in
            let isBlack (rb: Color) : Z :=
                match rb with
                | B => 1
                | R => 0
                end in
            
        (andb (andb aBool bBool) (aHeight =? bHeight), aHeight + isBlack rb)
        end in
    fst (go t).

Definition isRBT (t: Tree) : bool :=
    isBST t && consistentBlackHeight t && noRedRed t
.

Fixpoint toList (t: Tree) : list (Z * Z) :=
    match t with
    | E => nil
    | (T _ l k v r) =>
        toList l ++ [(k, v)] ++ toList r
    end.

(* ---------- *)
  
(* -- Validity properties. *)

Definition prop_InsertValid  (t: Tree) (k: Z) (v: Z) :=
  isRBT t -=> isRBT (insert k v t).

Definition prop_DeleteValid  (t: Tree) (k: Z) :=
  isRBT t -=> 
    (t' <- delete k t ;;
    Some (isRBT t')).

(* ---------- *)

(* -- Postcondition properties. *)

Definition prop_InsertPost  (t: Tree) (k: Z) (k': Z) (v: Z) :=
  isRBT t
    -=> (
    let v' := find k' (insert k v t) in
    if k =? k' then v' ==? Some v 
    else v' ==? find k' t)
.

Definition prop_DeletePost (t: Tree) (k: Z) (k': Z) :=
  isRBT t
    -=> Some(
    t' <- delete k t ;;
    find k' t'
    ==? if k =? k' then None else find k' t
    ).

(* ---------- *)

(* -- Model-based properties. *)

Definition deleteKey  (k: Z) (l: list (Z * Z)): list (Z * Z) :=
  filter (fun x => negb (fst x =? k)) l.

  Fixpoint L_insert (kv: Z * Z) (l: list (Z * Z)) : list (Z * Z) :=
    match l with
    | nil => [kv]
    | (k, v)::xs =>
      if fst kv =? k then (fst kv, snd kv)::xs
      else if fst kv <? k then (fst kv, snd kv)::l
      else (k, v)::(L_insert kv xs)
    end.


Definition prop_InsertModel  (t: Tree) (k: Z) (v: Z) :=
  isRBT t
    -=> 
    ((toList (insert k v t)) ==? (L_insert (k, v) (deleteKey k (toList t)))).



Definition prop_DeleteModel  (t: Tree) (k: Z) :=
  isRBT t
    -=> 
    t' <- delete k t ;;
    Some(toList t'
    ==? deleteKey k (toList t)).



(* ---------- *)

(* -- Metamorphic properties. *)

Definition prop_InsertInsert  (t: Tree) (k: Z) (k': Z) (v: Z) (v': Z) :=
  isRBT t
    -=> (toList (insert k v (insert k' v' t))
    ==? toList(if k =? k' then insert k v t else insert k' v' (insert k v t))).

Definition prop_InsertDelete (t: Tree) (k: Z) (k': Z) (v: Z)  :=
  isRBT t
    -=> 
    t' <- (delete k' t) ;;
    t'' <- delete k' (insert k v t) ;;
    Some(toList(insert k v t')
    ==? toList(if k =? k' then insert k v t else t'')).

Definition prop_DeleteInsert (t: Tree) (k: Z) (k': Z) (v': Z)  :=
  isRBT t
    -=> 
    t' <- delete k (insert k' v' t) ;;
    t'' <- delete k t ;;
    let t''' := insert k' v' t'' in
    Some(toList t' ==? toList (if k =? k' then t'' else t''')).

Definition prop_DeleteDelete  (t: Tree) (k: Z) (k': Z) :=
  isRBT t
    -=> 
    t' <- delete k' t ;;
    t'' <- delete k t' ;;
    t1' <- delete k t ;;
    t1'' <- delete k' t1' ;;
    Some (toList t'' ==? toList t1'').

(* ---------- *)

Definition sizeRBT  (t: Tree): nat :=
    length (toList t).
