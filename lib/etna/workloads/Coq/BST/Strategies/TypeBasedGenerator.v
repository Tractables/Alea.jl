From QuickChick Require Import QuickChick. Import QcNotation.
From Coq Require Import List. Import ListNotations.
From Coq Require Import ZArith.
From ExtLib Require Import Monad.
Import MonadNotation.

From BST Require Import Impl.
From BST Require Import Spec.

Derive (Arbitrary, Show) for Tree.

Definition gSized : G Tree := arbitrary.

Definition test_prop_InsertValid   :=
  forAll arbitrary (fun (t: Tree)  =>
  forAll arbitrary (fun (k: nat)  =>
  forAll arbitrary (fun (v: nat) =>
  prop_InsertValid t k v)))
.

(*! QuickChick test_prop_InsertValid. *)

Definition test_prop_DeleteValid   :=
  forAll arbitrary (fun (t: Tree)  =>
  forAll arbitrary (fun (k: nat) =>
  prop_DeleteValid t k))
.

(*! QuickChick test_prop_DeleteValid. *)


Definition test_prop_UnionValid    :=
  forAll arbitrary (fun (t1: Tree)  =>
  forAll arbitrary (fun (t2: Tree) =>
  prop_UnionValid t1 t2))
.

(*! QuickChick test_prop_UnionValid. *)

Definition test_prop_InsertPost    :=
  forAll arbitrary (fun (t: Tree)  =>
  forAll arbitrary (fun (k: nat)  =>
  forAll arbitrary (fun (k': nat)  =>
  forAll arbitrary (fun (v: nat) =>
  prop_InsertPost t k k' v))))
.

(*! QuickChick test_prop_InsertPost. *)

Definition test_prop_DeletePost    :=
  forAll arbitrary (fun (t: Tree)  =>
  forAll arbitrary (fun (k: nat)  =>
  forAll arbitrary (fun (k': nat) =>
  prop_DeletePost t k k')))
.

(*! QuickChick test_prop_DeletePost. *)

Definition test_prop_UnionPost   :=
  forAll arbitrary (fun (t: Tree)  =>
  forAll arbitrary (fun (t': Tree)  =>
  forAll arbitrary (fun (k: nat) =>
  prop_UnionPost t t' k)))
.

(*! QuickChick test_prop_UnionPost. *)

Definition test_prop_InsertModel   :=
  forAll arbitrary (fun (t: Tree)  =>
  forAll arbitrary (fun (k: nat)  =>
  forAll arbitrary (fun (v: nat) =>
  prop_InsertModel t k v)))
.

(*! QuickChick test_prop_InsertModel. *)

Definition test_prop_DeleteModel   :=
  forAll arbitrary (fun (t: Tree)  =>
  forAll arbitrary (fun (k: nat) =>
  prop_DeleteModel t k))
.

(*! QuickChick test_prop_DeleteModel. *)

Definition test_prop_UnionModel    :=
  forAll arbitrary (fun (t: Tree)  =>
  forAll arbitrary (fun (t': Tree) =>
  prop_UnionModel t t'))
.

(*! QuickChick test_prop_UnionModel. *)

Definition test_prop_InsertInsert    :=
  forAll arbitrary (fun (t: Tree)  =>
  forAll arbitrary (fun (k: nat)  =>
  forAll arbitrary (fun (k': nat)  =>
  forAll arbitrary (fun (v: nat)  =>
  forAll arbitrary (fun (v': nat) =>
  prop_InsertInsert t k k' v v')))))
.

(*! QuickChick test_prop_InsertInsert. *)

Definition test_prop_InsertDelete    :=
  forAll arbitrary (fun (t: Tree)  =>
  forAll arbitrary (fun (k: nat)  =>
  forAll arbitrary (fun (k': nat)  =>
  forAll arbitrary (fun (v: nat) =>
  prop_InsertDelete t k k' v))))
.

(*! QuickChick test_prop_InsertDelete. *)

Definition test_prop_InsertUnion   :=
  forAll arbitrary (fun (t: Tree)  =>
  forAll arbitrary (fun (t': Tree)  =>
  forAll arbitrary (fun (k: nat)  =>
  forAll arbitrary (fun (v: nat) =>
  prop_InsertUnion t t' k v))))
.

(*! QuickChick test_prop_InsertUnion. *)

Definition test_prop_DeleteInsert    :=
  forAll arbitrary (fun (t: Tree)  =>
  forAll arbitrary (fun (k: nat)  =>
  forAll arbitrary (fun (k': nat)  =>
  forAll arbitrary (fun (v': nat) =>
  prop_DeleteInsert t k k' v'))))
.

(*! QuickChick test_prop_DeleteInsert. *)

Definition test_prop_DeleteDelete    :=
  forAllShrink arbitrary shrink (fun (t: Tree)  =>
  forAllShrink arbitrary shrink (fun (k: nat)  =>
  forAllShrink arbitrary shrink (fun (k': nat) =>
  whenFail' (fun tt => show (t, k, k', delete k t, delete k' t, delete k (delete k' t), delete k' (delete k t)))
  (prop_DeleteDelete t k k'))))
.

(*! QuickChick test_prop_DeleteDelete. *)

Definition test_prop_DeleteUnion   :=
  forAll arbitrary (fun (t: Tree)  =>
  forAll arbitrary (fun (t': Tree)  =>
  forAll arbitrary (fun (k: nat) =>
  prop_DeleteUnion t t' k)))
.

(*! QuickChick test_prop_DeleteUnion. *)

Definition test_prop_UnionDeleteInsert   :=
  forAll arbitrary (fun (t :Tree)  =>
  forAll arbitrary (fun (t': Tree)  =>
  forAll arbitrary (fun (k: nat)  =>
  forAll arbitrary (fun (v: nat) =>
  prop_UnionDeleteInsert t t' k v))))
.

(*! QuickChick test_prop_UnionDeleteInsert. *)

Definition test_prop_UnionUnionIdem    :=
  forAll arbitrary (fun (t: Tree) =>
  prop_UnionUnionIdem t)
.

(*! QuickChick test_prop_UnionUnionIdem. *)

Definition test_prop_UnionUnionAssoc   :=
  forAll arbitrary (fun (t1: Tree)  =>
  forAll arbitrary (fun (t2: Tree)  =>
  forAll arbitrary (fun (t3: Tree) =>
  prop_UnionUnionAssoc t1 t2 t3)))
.

(*! QuickChick test_prop_UnionUnionAssoc. *)