
Require Import ZArith.
From QuickChick Require Import QuickChick.
From ExtLib Require Import Monad.
From ExtLib.Data.Monads Require Import OptionMonad.
Import QcNotation.
Import MonadNotation.
From Coq Require Import List.
Import ListNotations.


Local Open Scope Z_scope.

Notation "A <?? B" := (Z_lt_le_dec A B) (at level 70, no associativity).


Inductive Color := R | B.
Derive (Arbitrary, Show) for Color.


Inductive Tree :=
    | E : Tree
    | T : Color -> Tree -> Z -> Z -> Tree -> Tree.

Derive (Show) for Tree.

Axiom fuel : nat. Extract Constant fuel => "100000".

(* ---------- *)

(* -- Used for insert and delete. *)

Definition blacken (t: Tree) : Tree :=
    match t with
    | E => E
    | (T _ a x vx b) => T B a x vx b
    end.


Definition redden (t: Tree) : option Tree :=
    match t with
    | T B a x vx b => Some(T R a x vx b)
    | _ => None
    end.

Definition balance (col: Color) (tl: Tree) (key: Z) (val: Z) (tr: Tree) : Tree :=
    match col, tl, key, val, tr with
    (*! *)
    | B, (T R (T R a x vx b) y vy c), z, vz, d => T R (T B a x vx b) y vy (T B c z vz d)
(*!! swap_ad *)
(*! 
    | B, (T R (T R a x vx b) y vy c), z, vz, d => T R (T B a x vx b) y vy (T B d z vz c) 
*)
    | B, (T R a x vx (T R b y vy c)), z, vz, d => T R (T B a x vx b) y vy (T B c z vz d)
(*! *)
    | B, a, x, vx, (T R (T R b y vy c) z vz d) => T R (T B a x vx b) y vy (T B c z vz d)
(*!! swap_bc *)
(*! 
    | B, a, x, vx, (T R (T R b y vy c) z vz d) => T R (T B a x vx c) y vy (T B b z vz d) 
*)
    | B, a, x, vx, (T R b y vy (T R c z vz d)) => T R (T B a x vx b) y vy (T B c z vz d)
    | rb, a, x, vx, b => T rb a x vx b
    end.

(* ----------
 *)
Set Warnings "-non-recursive, -fixpoints".
Fixpoint insert (key: Z) (val: Z) (t: Tree) : Tree :=
    let fix ins (x: Z) (vx: Z) (s: Tree) : Tree :=
    match x, vx, s with
    | x, vx, E => 
    (*! *)
    T R E x vx E
    (*!! miscolor_insert *)
    (*! 
    T B E x vx E 
    *)
    | x, vx, (T rb a y vy b) =>
    (*! *)
    if x <?? y then balance rb (ins x vx a) y vy b
    else if y <?? x then balance rb a y vy (ins x vx b)
    else T rb a y vx b
    (*!! insert_1 *)
    (*!
    T R E x vx E
    *)
    (*!! insert_2 *)
    (*!
    if x <?? y then balance rb (ins x vx a) y vy b
    else T rb a y vx b
    *)
    (*!! insert_3 *)
    (*!
    if x <?? y then balance rb (ins x vx a) y vy b
    else if y <?? x then balance rb a y vy (ins x vx b)
    else T rb a y vy b
    *)
    (*!! no_balance_insert_1 *)
    (*!
    if x <?? y then T rb (ins x vx a) y vy b
    else if y <?? x then balance rb a y vy (ins x vx b)
    else T rb a y vx b
    *)
    (*!! no_balance_insert_2 *)
    (*!
    if x <?? y then balance rb (ins x vx a) y vy b
    else if y <?? x then T rb a y vy (insert x vx b)
    else T rb a y vx b
    *)
    end
    in blacken (ins key val t).

Set Warnings "+non-recursive, +fixpoints".

(* -- Based on https://www.cs.kent.ac.uk/people/staff/smk/redblack/Untyped.hs *)

Definition balLeft (tl: Tree) (k: Z) (v: Z) (tr: Tree) : option Tree :=
    match tl, k, v, tr with
    | (T R a x vx b), y, vy, c => Some (T R (T B a x vx b) y vy c)
    | bl, x, vx, (T B a y vy b) => Some (balance B bl x vx (T R a y vy b))
    | bl, x, vx, (T R (T B a y vy b) z vz c) =>
  (*! *)
    c' <- (redden c) ;;
    Some (T R (T B bl x vx a) y vy (balance B b z vz c'))
  (*!! miscolor_balLeft *) 
  (*! 
  Some (T R (T B bl x vx a) y vy (balance B b z vz c) )
  *)
    | _, _, _, _ => None
    end.


Definition balRight (tl: Tree) (k: Z) (v: Z) (tr: Tree) : option Tree :=
    match tl, k, v, tr with
    | a, x, vx, (T R b y vy c) => Some(T R a x vx (T B b y vy c))
    | (T B a x vx b), y, vy, bl => Some(balance B (T R a x vx b) y vy bl)
    | (T R a x vx (T B b y vy c)), z, vz, bl =>
    (*! *)
        a' <- redden a ;;
        Some (T R (balance B a' x vx b) y vy (T B c z vz bl))
    (*!! miscolor_balRight *) 
    (*! 
        Some (T R (balance B a x vx b) y vy (T B c z vz bl) )
    *)
    | _, _, _, _ => None
    end.

Fixpoint _join (t1: Tree) (t2: Tree) (f: nat) : option Tree :=
    match f with
    | O => None
    | S f' =>
        match t1, t2 with
        | E, a => Some a
        | a, E => Some a
        | (T R a x vx b), (T R c y vy d) =>
            match _join b c f' with
            | None => None
            | Some(T R b' z vz c') => 
            (*! *)
                Some (T R (T R a x vx b') z vz (T R c' y vy d))
            (*!! miscolor_join_1 *)
            (*! 
            Some(T R (T B a x vx b') z vz (T B c' y vy d))
            *)
            | Some(bc) => Some(T R a x vx (T R bc y vy d))
            end
        | (T B a x vx b), (T B c y vy d) =>
            match _join b c f' with
            | None => None
            | Some(T R b' z vz c') => 
            (*! *)
            Some(T R (T B a x vx b') z vz (T B c' y vy d))
            (*!! miscolor_join_2 *)
            (*! 
            Some(T R (T R a x vx b') z vz (T R c' y vy d))
            *)
            | Some(bc) => 
                balLeft a x vx (T B bc y vy d)
            end
        | a, (T R b x vx c) => 
            match _join a b f' with
            | None => None
            | Some t' =>
                Some (T R t' x vx c)
            end
        | (T R a x vx b), c => 
            t' <- _join b c f' ;;
            Some (T R a x vx t')
        end 
    end.

Definition join (t1: Tree) (t2: Tree) : option Tree :=
    _join t1 t2 fuel.
(* ---------- *)


Fixpoint del (x: Z) (s: Tree) (f: nat) : option Tree :=
    match f with
    | O => None
    | S f' =>
        match s with
        | E => Some E
        | (T _ a y vy b) =>
            (*! *)
            if x <?? y then 
                t' <- delLeft x a y vy b f' ;;
                Some t'
            else if y <?? x then 
                t' <- delRight x a y vy b f' ;;
                Some t'
            else 
                t' <- join a b ;;
                Some t'
            (*!! delete_4 *)
            (*!
            let _tmp := delLeft in
            let _tmp := delRight in
            if x <?? y then del x a f'
            else if y <?? x then del x b f'
            else join a b 
            *)
            (*!! delete_5 *)
            (*!
            if y <?? x then delLeft x a y vy b f'
            else if x <?? y then delRight x a y vy b f'
            else join a b
            *)
        end
    end
with delLeft (x: Z) (dl: Tree) (dy: Z) (dvy: Z) (dr: Tree) (f: nat): option Tree :=
    match f with
    | O => None
    | S f' =>
        match dl, dy, dvy, dr with
        | (T B al ax avx ar), y, vy, b => 
            t' <- (del x (T B al ax avx ar) f') ;;
            t'' <- balLeft t' y vy b ;;
            Some t''
        | a, y, vy, b => 
            t' <- del x a f' ;;
            Some (T R t' y vy b)
        end
    end
with delRight (x: Z) (dl: Tree) (dy: Z) (dvy: Z) (dr: Tree) (f: nat): option Tree :=
    match f with
    | O => None
    | S f' =>
        match dl, dy, dvy, dr with
        | a, y, vy, (T B bl bx bvx br) => 
            t' <- (del x (T B bl bx bvx br) f') ;;
            t'' <- balRight a y vy t' ;;
            Some t''
        | a, y, vy, b => 
            t' <- del x b f' ;;
            Some (T R a y vy t')
        end
    end.

Definition delete (x: Z) (t: Tree) : option Tree :=
    (*! *)
    t' <- del x t fuel ;;
    Some (blacken t')
    (*!! miscolordelete *)
    (*!
    del x t fuel
    *)
    .



Fixpoint find (x: Z) (t: Tree) : option Z :=
    match t with
    | E => None
    | (T _ l y vy r) =>
        if x <?? y then find x l
        else if y <?? x then find x r
        else (Some vy)
    end.


Fixpoint size (t: Tree) : nat :=
  match t with
  | E => 0
  | T c l k v r => 1 + size l + size r
  end.

(* Definition mytree2 := E.
Definition mytree := T R E 0 ((-7)) E.

Definition trees__ :=
    [E; E; E; T R E 0 (-7) E; T R E 4 5 (T B (T B (T R E (-3) 3 (T R E 1 4 E)) 6 (-1) (T R (T R E (-2) (-6) E) 1 4 E)) (-3) 3 (T B E (-6) 6 E)); T R E 4 (-4) E; T B (T B (T B (T R E 2 3 (T R E 2 (-1) E)) (-2) 4 E) (-3) 3 (T R (T B E 1 (-1) E) 4 2 E)) 4 3 E; T B (T R E (-1) 0 (T B (T R (T B E 1 1 E) 2 3 E) 0 2 E)) 1 1 E; T R E (-1) (-1) (T B (T B E (-2) 2 (T R (T B E (-2) (-2) E) 0 1 (T B E 2 (-1) E))) 1 0 (T R E 2 1 (T B (T B E 0 (-1) E) 1 (-1) (T B E 0 1 E)))); E; T R E 0 0 (T B E 0 0 E)].

Print trees__.

Derive (Arbitrary, Shrink) for Tree.
(* Sample (arbitrarySized {Tree} 5). *)

Definition sizes := map size trees__.

Print sizes. *)