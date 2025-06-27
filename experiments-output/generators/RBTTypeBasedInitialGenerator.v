Require Import ZArith.
From QuickChick Require Import QuickChick.
From ExtLib Require Import Monad.
From ExtLib.Data.Monads Require Import OptionMonad.
Import QcNotation.
Import MonadNotation.
From Coq Require Import List.
Import ListNotations.

From RBT Require Import Impl Spec.

Inductive CtorTree :=
  | CtorTree_E
  | CtorTree_T.

Inductive LeafCtorTree :=
  | LeafCtorTree_E.

Inductive LeafCtorColor :=
  | LeafCtorColor_R
  | LeafCtorColor_B.

Inductive TupLeafCtorColorCtorTreeCtorTree :=
  | MkLeafCtorColorCtorTreeCtorTree : LeafCtorColor -> CtorTree -> CtorTree -> TupLeafCtorColorCtorTreeCtorTree.

Inductive TupLeafCtorColorLeafCtorTreeLeafCtorTree :=
  | MkLeafCtorColorLeafCtorTreeLeafCtorTree : LeafCtorColor -> LeafCtorTree -> LeafCtorTree -> TupLeafCtorColorLeafCtorTreeLeafCtorTree.

Definition genLeafColor (chosen_ctor : LeafCtorColor) (stack1 : nat) (stack2 : nat) : G (Color) :=
  match chosen_ctor with
  | LeafCtorColor_R => 
    (returnGen (R ))
  | LeafCtorColor_B => 
    (returnGen (B ))
  end.

Definition genLeafTree (chosen_ctor : LeafCtorTree) (stack1 : nat) (stack2 : nat) : G (Tree) :=
  match chosen_ctor with
  | LeafCtorTree_E => 
    (returnGen (E ))
  end.

Fixpoint genTree (size : nat) (chosen_ctor : CtorTree) (stack1 : nat) (stack2 : nat) : G (Tree) :=
  match size with
  | O  => match chosen_ctor with
    | CtorTree_E => 
      (returnGen (E ))
    | CtorTree_T => 
      (bindGen 
      (* Frequency2 *) (freq [
        (* 1 *) (match (stack1, stack2) with
        | (4, 4) => 50
        | (4, 6) => 50
        | (6, 4) => 50
        | (6, 6) => 50
        | _ => 500
        end,
        (returnGen (MkLeafCtorColorLeafCtorTreeLeafCtorTree LeafCtorColor_R LeafCtorTree_E LeafCtorTree_E))); 
        (* 2 *) (match (stack1, stack2) with
        | (4, 4) => 50
        | (4, 6) => 50
        | (6, 4) => 50
        | (6, 6) => 50
        | _ => 500
        end,
        (returnGen (MkLeafCtorColorLeafCtorTreeLeafCtorTree LeafCtorColor_B LeafCtorTree_E LeafCtorTree_E)))]) 
      (fun param_variantis => (let '(MkLeafCtorColorLeafCtorTreeLeafCtorTree ctor1 ctor2 ctor3) := param_variantis in

        (bindGen (genLeafColor ctor1 stack2 1) 
        (fun p1 => 
          (bindGen (genLeafTree ctor2 stack2 3) 
          (fun p2 => 
            (bindGen 
            (* GenZ1 *)
            (let _weight_1 := match (stack1, stack2) with
            | (4, 4) => 50
            | (4, 6) => 50
            | (6, 4) => 50
            | (6, 6) => 50
            | _ => 500
            end
            in
            bindGen (freq [
              (_weight_1, returnGen 1%Z);
              (100-_weight_1, returnGen 0%Z)
            ]) (fun n1 =>
            (let _weight_2 := match (stack1, stack2) with
            | (4, 4) => 50
            | (4, 6) => 50
            | (6, 4) => 50
            | (6, 6) => 50
            | _ => 500
            end
            in
            bindGen (freq [
              (_weight_2, returnGen 2%Z);
              (100-_weight_2, returnGen 0%Z)
            ]) (fun n2 =>
            (let _weight_4 := match (stack1, stack2) with
            | (4, 4) => 50
            | (4, 6) => 50
            | (6, 4) => 50
            | (6, 6) => 50
            | _ => 500
            end
            in
            bindGen (freq [
              (_weight_4, returnGen 4%Z);
              (100-_weight_4, returnGen 0%Z)
            ]) (fun n4 =>
              returnGen (n1 + n2 + n4)%Z
            )))))) 
            (fun p3 => 
              (bindGen 
              (* GenZ3 *)
              (let _weight_1 := match (stack1, stack2) with
              | (4, 4) => 50
              | (4, 6) => 50
              | (6, 4) => 50
              | (6, 6) => 50
              | _ => 500
              end
              in
              bindGen (freq [
                (_weight_1, returnGen 1%Z);
                (100-_weight_1, returnGen 0%Z)
              ]) (fun n1 =>
              (let _weight_2 := match (stack1, stack2) with
              | (4, 4) => 50
              | (4, 6) => 50
              | (6, 4) => 50
              | (6, 6) => 50
              | _ => 500
              end
              in
              bindGen (freq [
                (_weight_2, returnGen 2%Z);
                (100-_weight_2, returnGen 0%Z)
              ]) (fun n2 =>
              (let _weight_4 := match (stack1, stack2) with
              | (4, 4) => 50
              | (4, 6) => 50
              | (6, 4) => 50
              | (6, 6) => 50
              | _ => 500
              end
              in
              bindGen (freq [
                (_weight_4, returnGen 4%Z);
                (100-_weight_4, returnGen 0%Z)
              ]) (fun n4 =>
                returnGen (n1 + n2 + n4)%Z
              )))))) 
              (fun p4 => 
                (bindGen (genLeafTree ctor3 stack2 5) 
                (fun p5 => 
                  (returnGen (T p1 p2 p3 p4 p5)))))))))))))))
    end
  | S size1 => match chosen_ctor with
    | CtorTree_E => 
      (returnGen (E ))
    | CtorTree_T => 
      (bindGen 
      (* Frequency3 *) (freq [
        (* 1 *) (match (size, stack1, stack2) with
        | (1, 4, 4) => 50
        | (1, 4, 6) => 50
        | (1, 6, 4) => 50
        | (1, 6, 6) => 50
        | (2, 0, 4) => 50
        | (2, 0, 6) => 50
        | (3, 0, 0) => 50
        | _ => 500
        end,
        (returnGen (MkLeafCtorColorCtorTreeCtorTree LeafCtorColor_R CtorTree_E CtorTree_E))); 
        (* 2 *) (match (size, stack1, stack2) with
        | (1, 4, 4) => 50
        | (1, 4, 6) => 50
        | (1, 6, 4) => 50
        | (1, 6, 6) => 50
        | (2, 0, 4) => 50
        | (2, 0, 6) => 50
        | (3, 0, 0) => 50
        | _ => 500
        end,
        (returnGen (MkLeafCtorColorCtorTreeCtorTree LeafCtorColor_B CtorTree_E CtorTree_E))); 
        (* 3 *) (match (size, stack1, stack2) with
        | (1, 4, 4) => 50
        | (1, 4, 6) => 50
        | (1, 6, 4) => 50
        | (1, 6, 6) => 50
        | (2, 0, 4) => 50
        | (2, 0, 6) => 50
        | (3, 0, 0) => 50
        | _ => 500
        end,
        (returnGen (MkLeafCtorColorCtorTreeCtorTree LeafCtorColor_R CtorTree_T CtorTree_E))); 
        (* 4 *) (match (size, stack1, stack2) with
        | (1, 4, 4) => 50
        | (1, 4, 6) => 50
        | (1, 6, 4) => 50
        | (1, 6, 6) => 50
        | (2, 0, 4) => 50
        | (2, 0, 6) => 50
        | (3, 0, 0) => 50
        | _ => 500
        end,
        (returnGen (MkLeafCtorColorCtorTreeCtorTree LeafCtorColor_B CtorTree_T CtorTree_E))); 
        (* 5 *) (match (size, stack1, stack2) with
        | (1, 4, 4) => 50
        | (1, 4, 6) => 50
        | (1, 6, 4) => 50
        | (1, 6, 6) => 50
        | (2, 0, 4) => 50
        | (2, 0, 6) => 50
        | (3, 0, 0) => 50
        | _ => 500
        end,
        (returnGen (MkLeafCtorColorCtorTreeCtorTree LeafCtorColor_R CtorTree_E CtorTree_T))); 
        (* 6 *) (match (size, stack1, stack2) with
        | (1, 4, 4) => 50
        | (1, 4, 6) => 50
        | (1, 6, 4) => 50
        | (1, 6, 6) => 50
        | (2, 0, 4) => 50
        | (2, 0, 6) => 50
        | (3, 0, 0) => 50
        | _ => 500
        end,
        (returnGen (MkLeafCtorColorCtorTreeCtorTree LeafCtorColor_B CtorTree_E CtorTree_T))); 
        (* 7 *) (match (size, stack1, stack2) with
        | (1, 4, 4) => 50
        | (1, 4, 6) => 50
        | (1, 6, 4) => 50
        | (1, 6, 6) => 50
        | (2, 0, 4) => 50
        | (2, 0, 6) => 50
        | (3, 0, 0) => 50
        | _ => 500
        end,
        (returnGen (MkLeafCtorColorCtorTreeCtorTree LeafCtorColor_R CtorTree_T CtorTree_T))); 
        (* 8 *) (match (size, stack1, stack2) with
        | (1, 4, 4) => 50
        | (1, 4, 6) => 50
        | (1, 6, 4) => 50
        | (1, 6, 6) => 50
        | (2, 0, 4) => 50
        | (2, 0, 6) => 50
        | (3, 0, 0) => 50
        | _ => 500
        end,
        (returnGen (MkLeafCtorColorCtorTreeCtorTree LeafCtorColor_B CtorTree_T CtorTree_T)))]) 
      (fun param_variantis => (let '(MkLeafCtorColorCtorTreeCtorTree ctor1 ctor2 ctor3) := param_variantis in

        (bindGen (genLeafColor ctor1 stack2 2) 
        (fun p1 => 
          (bindGen (genTree size1 ctor2 stack2 4) 
          (fun p2 => 
            (bindGen 
            (* GenZ2 *)
            (let _weight_1 := match (size, stack1, stack2) with
            | (1, 4, 4) => 50
            | (1, 4, 6) => 50
            | (1, 6, 4) => 50
            | (1, 6, 6) => 50
            | (2, 0, 4) => 50
            | (2, 0, 6) => 50
            | (3, 0, 0) => 50
            | _ => 500
            end
            in
            bindGen (freq [
              (_weight_1, returnGen 1%Z);
              (100-_weight_1, returnGen 0%Z)
            ]) (fun n1 =>
            (let _weight_2 := match (size, stack1, stack2) with
            | (1, 4, 4) => 50
            | (1, 4, 6) => 50
            | (1, 6, 4) => 50
            | (1, 6, 6) => 50
            | (2, 0, 4) => 50
            | (2, 0, 6) => 50
            | (3, 0, 0) => 50
            | _ => 500
            end
            in
            bindGen (freq [
              (_weight_2, returnGen 2%Z);
              (100-_weight_2, returnGen 0%Z)
            ]) (fun n2 =>
            (let _weight_4 := match (size, stack1, stack2) with
            | (1, 4, 4) => 50
            | (1, 4, 6) => 50
            | (1, 6, 4) => 50
            | (1, 6, 6) => 50
            | (2, 0, 4) => 50
            | (2, 0, 6) => 50
            | (3, 0, 0) => 50
            | _ => 500
            end
            in
            bindGen (freq [
              (_weight_4, returnGen 4%Z);
              (100-_weight_4, returnGen 0%Z)
            ]) (fun n4 =>
              returnGen (n1 + n2 + n4)%Z
            )))))) 
            (fun p3 => 
              (bindGen 
              (* GenZ4 *)
              (let _weight_1 := match (size, stack1, stack2) with
              | (1, 4, 4) => 50
              | (1, 4, 6) => 50
              | (1, 6, 4) => 50
              | (1, 6, 6) => 50
              | (2, 0, 4) => 50
              | (2, 0, 6) => 50
              | (3, 0, 0) => 50
              | _ => 500
              end
              in
              bindGen (freq [
                (_weight_1, returnGen 1%Z);
                (100-_weight_1, returnGen 0%Z)
              ]) (fun n1 =>
              (let _weight_2 := match (size, stack1, stack2) with
              | (1, 4, 4) => 50
              | (1, 4, 6) => 50
              | (1, 6, 4) => 50
              | (1, 6, 6) => 50
              | (2, 0, 4) => 50
              | (2, 0, 6) => 50
              | (3, 0, 0) => 50
              | _ => 500
              end
              in
              bindGen (freq [
                (_weight_2, returnGen 2%Z);
                (100-_weight_2, returnGen 0%Z)
              ]) (fun n2 =>
              (let _weight_4 := match (size, stack1, stack2) with
              | (1, 4, 4) => 50
              | (1, 4, 6) => 50
              | (1, 6, 4) => 50
              | (1, 6, 6) => 50
              | (2, 0, 4) => 50
              | (2, 0, 6) => 50
              | (3, 0, 0) => 50
              | _ => 500
              end
              in
              bindGen (freq [
                (_weight_4, returnGen 4%Z);
                (100-_weight_4, returnGen 0%Z)
              ]) (fun n4 =>
                returnGen (n1 + n2 + n4)%Z
              )))))) 
              (fun p4 => 
                (bindGen (genTree size1 ctor3 stack2 6) 
                (fun p5 => 
                  (returnGen (T p1 p2 p3 p4 p5)))))))))))))))
    end
  end.

Definition gSized :=

  (bindGen 
  (* Frequency1 *) (freq [
    (* 1 *) (match (tt) with
    | tt => 50
    end,
    (returnGen CtorTree_E)); 
    (* 2 *) (match (tt) with
    | tt => 50
    end,
    (returnGen CtorTree_T))]) 
  (fun init_ctor => (genTree 3 init_ctor 0 0))).

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
          
