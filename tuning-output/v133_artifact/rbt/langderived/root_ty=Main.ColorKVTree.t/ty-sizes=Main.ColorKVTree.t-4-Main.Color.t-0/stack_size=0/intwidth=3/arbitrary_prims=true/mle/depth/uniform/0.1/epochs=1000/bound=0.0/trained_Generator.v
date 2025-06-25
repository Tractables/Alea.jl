Require Import ZArith.
From QuickChick Require Import QuickChick.
From ExtLib Require Import Monad.
From ExtLib.Data.Monads Require Import OptionMonad.
Import QcNotation.
Import MonadNotation.
From Coq Require Import List.
Import ListNotations.

From RBT Require Import Impl Spec.

Definition genColor (size : nat) : G (Color) :=

  (* Frequency1 *) (freq [
    (* R *) (match (size) with
    | (0) => 50
    | _ => 500
    end,
    (returnGen (R ))); 
    (* B *) (match (size) with
    | (0) => 50
    | _ => 500
    end,
    (returnGen (B )))]).

Fixpoint genTree (size : nat) : G (Tree) :=
  match size with
  | O  => 
    (* Frequency2 (single-branch) *) 
    (returnGen (E ))
  | S size1 => 
    (* Frequency3 *) (freq [
      (* E *) (match (size) with
      | (1) => 70
      | (2) => 62
      | (3) => 50
      | (4) => 18
      | _ => 500
      end,
      (returnGen (E ))); 
      (* T *) (match (size) with
      | (1) => 21
      | (2) => 34
      | (3) => 50
      | (4) => 71
      | _ => 500
      end,
      (bindGen (genColor 0) 
      (fun p1 => 
        (bindGen (genTree size1) 
        (fun p2 => 
          (bindGen 
          arbitrary 
          (fun p3 => 
            (bindGen 
            arbitrary 
            (fun p4 => 
              (bindGen (genTree size1) 
              (fun p5 => 
                (returnGen (T p1 p2 p3 p4 p5)))))))))))))])
  end.

Definition gSized :=
  (genTree 4).

(* --------------------- Tests --------------------- *)

Definition test_prop_InsertValid :=  
    forAll gSized (fun t =>    
    forAll arbitrary (fun k =>
    forAll arbitrary (fun v =>
        (prop_InsertValid t k v)))).

(*! QuickChick test_prop_InsertValid. *)

Definition test_prop_DeleteValid :=  
    forAll gSized (fun t =>    
    forAll arbitrary (fun k =>
        prop_DeleteValid t k)).

(*! QuickChick test_prop_DeleteValid. *)

Definition test_prop_InsertPost :=  
    forAll gSized (fun t =>    
    forAll arbitrary (fun k =>
    forAll arbitrary (fun k' =>
     forAll arbitrary (fun v =>
        prop_InsertPost t k k' v)))).

(*! QuickChick test_prop_InsertPost. *)

Definition test_prop_DeletePost := 
    forAll gSized (fun t =>    
    forAll arbitrary (fun k =>
    forAll arbitrary (fun k' =>
        prop_DeletePost t k k'))).

(*! QuickChick test_prop_DeletePost. *)
    
Definition test_prop_InsertModel :=  
    forAll gSized (fun t =>    
    forAll arbitrary (fun k =>
    forAll arbitrary (fun v =>
        prop_InsertModel t k v))).

(*! QuickChick test_prop_InsertModel. *)
    
Definition test_prop_DeleteModel :=  
    forAll gSized (fun t =>    
    forAll arbitrary (fun k =>
            prop_DeleteModel t k)).

(*! QuickChick test_prop_DeleteModel. *)

Definition test_prop_InsertInsert :=  
    forAll gSized (fun t =>    
    forAll arbitrary (fun k =>
    forAll arbitrary (fun k' =>
    forAll arbitrary (fun v =>
    forAll arbitrary (fun v' =>     
        prop_InsertInsert t k k' v v'))))).

(*! QuickChick test_prop_InsertInsert. *)
    
Definition test_prop_InsertDelete := 
    forAll gSized (fun t =>    
    forAll arbitrary (fun k =>
    forAll arbitrary (fun k' =>
    forAll arbitrary (fun v =>
        prop_InsertDelete t k k' v)))).

(*! QuickChick test_prop_InsertDelete. *)
    
Definition test_prop_DeleteInsert := 
    forAll gSized (fun t =>    
    forAll arbitrary (fun k =>
    forAll arbitrary (fun k' =>
    forAll arbitrary (fun v' =>
        prop_DeleteInsert t k k' v')))).

(*! QuickChick test_prop_DeleteInsert. *)
    
Definition test_prop_DeleteDelete :=  
    forAll gSized (fun t =>    
    forAll arbitrary (fun k =>
    forAll arbitrary (fun k' =>
        prop_DeleteDelete t k k'))).

(*! QuickChick test_prop_DeleteDelete. *)
          
