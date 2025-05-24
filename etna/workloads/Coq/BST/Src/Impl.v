
Require Import List ZArith. Import ListNotations.
Require Extraction.
From QuickChick Require Import QuickChick.
Import QcNotation.

Inductive Tree :=
| E 
| T : Tree -> nat -> nat -> Tree -> Tree.

Derive (Show) for Tree.


Axiom fuel : nat. Extract Constant fuel => "100000".



Fixpoint insert (k : nat) (v: nat) (t : Tree) :=
  match t with
  | E => T E k v E
  | T l k' v' r => 
  (*! *)                 
    if k <? k' then T (insert k v l) k' v' r 
    else if k' <? k then T l k' v' (insert k v r) 
    else T l k' v r
  (*!! insert_1  *)
  (*!
    T E k v E
  *)
  (*!! insert_2 *)
(*!
  if k <? k' then T (insert k v l) k' v' r
  else T l k' v r *)
 
  (*!! insert_3 *)
  (*!
  if k <? k' then T (insert k v l) k' v' r
  else if k' <? k then T l k' v' (insert k v r)
  else T l k' v' r
  *)
  end.

Fixpoint join (l: Tree) (r: Tree) :=
  match l, r with
  | E, _ => r
  | _, E => l
  | T l k v r, T l' k' v' r' =>
    T l k v (T (join r l') k' v' r')
  end
.
  

Fixpoint delete (k: nat) (t: Tree) :=
  match t with
  | E => E
  | T l k' v' r =>
  (*! *)
  if k <? k' then T (delete k l) k' v' r
  else if k' <? k then T l k' v' (delete k r)
  else join l r
  (*!! delete_4 *)
  (*!
  if k <? k' then delete k l
  else if k' <? k then delete k r
  else join l r
  *)
  (*!! delete_5 *)
  (*!
  if k' <? k then T (delete k l) k' v' r
  else if k <? k' then T l k' v' (delete k r)
  else join l r
  *)
  end.



Fixpoint below (k: nat) (t: Tree) :=
  match k, t with
  | _, E => E
  | k, T l k' v r =>
    if k <=? k' then below k l
    else T l k' v (below k r)
  end.

Fixpoint above (k: nat) (t: Tree) :=
  match k, t with
  | _, E => E
  | k, (T l k' v r) =>
    if k' <=? k then above k r
    else T (above k l) k' v r
  end.




Fixpoint union_ (l: Tree) (r: Tree) (f: nat) :=
  match f with
  | 0 => E
  | S f' =>
    match l, r with
    | E, _ => r
    | _, E => l
    (*! *)
    | (T l k v r), t =>
      T (union_ l (below k t) f') k v (union_ r (above k t) f')
    (*!! union_6 *)
    (*!
    | (T l k v r), (T l' k' v' r') =>
      T l k v (T (union_ r l' f') k' v' r')
    *)
    (*!! union_7 *)
    (*!     
    | (T l k v r), (T l' k' v' r') =>
      if k =? k' then T (union_ l l' f') k v (union_ r r' f')
      else if k <? k' then T l k v (T (union_ r l' f') k' v' r')
      else union_ (T l' k' v' r') (T l k v r) f'
    *)
    (*!! union_8 *)
    (*!
    | (T l k v r), (T l' k' v' r') =>
    if k =? k'  then T (union_ l l' f') k v (union_ r r' f')
    else if k <? k'   then T (union_ l (below k l') f') k v
                            (union_ r (T (above k l') k' v' r') f')
      else union_ (T l' k' v' r') (T l k v r) f' 
    *)
    end
  end
.

Definition union (l: Tree) (r: Tree) :=
  union_ l r fuel.


Fixpoint find (k: nat) (t: Tree): option nat :=
  match k, t with
  | _, E => None
  | k, (T l k' v' r) =>
    if k <? k' then find k l
    else if k' <? k then find k r
    else Some v'
  end
.


Fixpoint size (t: Tree) :=
  match t with
  | E => 0
  | T l k v r => 1 + size l + size r
  end
.






