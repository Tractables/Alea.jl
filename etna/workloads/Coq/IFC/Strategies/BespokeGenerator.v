From QuickChick Require Import QuickChick.

Require Import TestingCommon.
Require Import Reachability.
Require Import SSNI.
Require Import SanityChecks.
Require Import ZArith.

From mathcomp Require Import ssreflect eqtype seq.
Import LabelEqType.

Local Open Scope nat_scope.

(* ------------------------------------------------------ *)
(* ---------------- Constants --------------------------- *)
(* ------------------------------------------------------ *)

Module C.

(* Currently constant frames/sizes - no need for more *)
(* But we *could* generate arbitrary stuff now ! :D  *)
Definition min_no_frames := 2.
Definition max_no_frames := 2.
Definition min_frame_size := 2%Z.
Definition max_frame_size := 2%Z.

(* Could also vary this - but no need *)
Definition code_len := 2.

Definition min_no_prins := 2.
Definition max_no_prins := 4.

Definition no_registers := 10.
End C.

Definition prop_stamp_generation (st : SState) : option bool :=
    Some (well_formed st).

  
(* Helpers to generate a Z within range (0, x) *)
Definition gen_from_length (len : Z) :=
  choose (0, len - 1)%Z.

Definition gen_from_nat_length (len : nat) :=
  choose (0, Z.of_nat len - 1)%Z.

(* ------------------------------------------------------ *)
(* ----- Generation of primitives ----------------------- *)
(* ------------------------------------------------------ *)

Record Info := MkInfo
  { def_block : mframe           (* Default Block (sad)               *)
  ; code_len  : Z                 (* Length of instruction list        *)
  ; data_len  : list (mframe * Z) (* Existing frames and their lengths *)
  ; no_regs   : nat               (* Number of Registers               *)
  }.

Class SmartGen (A : Type) := {
  smart_gen : Info -> G A
}.

Definition gen_BinOpT : G BinOpT :=
  elems_ BAdd [:: BAdd; BMult; BJoin; BFlowsTo; BEq].

(* Labels *)

Definition gen_label : G Label :=
  elems_ bot all_labels.

Definition gen_label_between_lax (l1 l2 : Label) : G Label :=
  elems_ l2 (filter (fun l => isLow l1 l) (allThingsBelow l2)).

Definition gen_label_between_strict (l1 l2 : Label) : G Label :=
  elems_ l2 (filter (fun l => isLow l1 l && negb (eqtype.eq_op l l1))%bool
                      (allThingsBelow l2)).

Instance smart_gen_label : SmartGen Label :=
{|
  smart_gen _info := gen_label
|}.

Definition gen_high_label (obs : Label) : G Label :=
  elems_ H (filter (fun l => negb (isLow l obs)) (allThingsBelow H)).

(* Pointers *)
Definition gen_pointer (inf : Info) : G Pointer :=
    let '(MkInfo def _ dfs _) := inf in
    bindGen (elems_ (def, Z0) dfs) (fun mfl =>
    let (mf, len) := mfl in
    bindGen (gen_from_length len) (fun addr =>
    returnGen (Ptr mf addr))).

Instance smart_gen_pointer : SmartGen Pointer :=
  {|
    smart_gen := gen_pointer
  |}.

(* Ints *)
Definition gen_int (inf : Info) : G Z :=
  freq_ (pure Z0)
            [:: (10, arbitrary);
                (1 , pure Z0);
                (10, gen_from_length (code_len inf))].

Instance smart_gen_int : SmartGen Z :=
  {|
    smart_gen := gen_int
  |}.

(* Values *)

Definition gen_value (inf : Info) : G Value :=
  let '(MkInfo def cl dfs _) := inf in
    freq_ (liftGen Vint arbitrary)
              [:: (1, liftGen Vint  (smart_gen inf));
                      (* prefering 0 over other integers (because of BNZ);
                         prefering valid code pointers over invalid ones *)
                  (1, liftGen Vptr  (smart_gen inf));
                  (1, liftGen Vlab  (smart_gen inf))].

Instance smart_gen_value : SmartGen Value :=
  {|
    smart_gen := gen_value
  |}.

(* Atoms *)

Definition gen_atom (inf : Info) : G Atom :=
  liftGen2 Atm (smart_gen inf) (smart_gen inf).

Instance smart_gen_atom : SmartGen Atom :=
  {|
    smart_gen := gen_atom
  |}.

(* PC *)

Definition gen_PC (inf : Info) : G Ptr_atom :=
  bindGen (smart_gen inf) (fun pcLab =>
  bindGen (gen_from_length (code_len inf)) (fun pcPtr =>
  returnGen (PAtm pcPtr pcLab))).

Instance smart_gen_pc : SmartGen Ptr_atom :=
  {|
    smart_gen := gen_PC
  |}.

(* ------------------------------------------------------ *)
(* --- Generation of groups of primitives --------------- *)
(* ------------------------------------------------------ *)

(* Generate a correct register file *)

Definition gen_registers (inf : Info) : G regSet :=
  vectorOf (no_regs inf) (smart_gen inf).

Instance smart_gen_registers : SmartGen regSet :=
  {|
    smart_gen := gen_registers
  |}.

Definition smart_gen_stack_loc inf : G StackFrame :=
    bindGen (smart_gen inf) (fun regs =>
    bindGen (smart_gen inf) (fun pc   =>
    bindGen (gen_from_nat_length (no_regs inf)) (fun target =>
    bindGen (smart_gen inf) (fun retLab =>
    returnGen (SF pc regs target retLab))))).

(* Creates the stack. For SSNI just one is needed *)
(* Make sure the stack invariant is preserved
 - no need since we only create one *)(* CH: probably wrong *)
Definition smart_gen_stack inf : G Stack :=
  freq_ (pure (ST nil))
            [:: (1, pure (ST nil));
                (9, bindGen (smart_gen_stack_loc inf) (fun sl =>
                    returnGen (ST [:: sl])))].

(* ------------------------------------------------------ *)
(* ---------- Instruction generation -------------------- *)
(* ------------------------------------------------------ *)

(* Groups registers into 4 groups, based on their content
   (data pointers, numeric and labels)
*)
Fixpoint groupRegisters (st : SState) (rs : regSet)
         (dptr cptr num lab : list regId) (n : Z) :=
  match rs with
    | nil => (dptr, cptr, num, lab)
    | (Vint i @ _) :: rs' =>
      let cptr' := if (Z.leb 0 i && Z.ltb i (Z_of_nat (List.length (st_imem st))))%bool
                   then n :: cptr else cptr in
      groupRegisters st rs' dptr cptr' (n :: num) lab (Z.succ n)
    | (Vptr p @ _ ) :: rs' =>
      groupRegisters st rs' (n :: dptr) cptr num lab (Z.succ n)
    | (Vlab _ @ _) :: rs' =>
      groupRegisters st rs' dptr cptr num (n :: lab) (Z.succ n)
  end.

Definition onNonEmpty {A : Type} (l : list A) (n : nat) :=
  match l with
    | nil => 0
    | _   => n
  end.

(* CH: TODO: Look at the large weights and try to lower them
   while preserving a near to uniform distribution;
   currently boosting BCalls, Alloc, and Store  *)

Definition ainstrSSNI (st : SState) : G Instr :=
  let '(St im m stk regs pc ) := st in
  let '(dptr, cptr, num, lab) :=
      groupRegisters st regs [::] [::] [::] [::] Z0 in
  let genRegPtr := gen_from_length (Zlength regs) in
  freq_ (pure Nop) [::
    (* Nop *)
    (1, pure Nop);
    (* Halt *)
    (0, pure Halt);
    (* PcLab *)
    (10, liftGen PcLab genRegPtr);
    (* Lab *)
    (10, liftGen2 Lab genRegPtr genRegPtr);
    (* MLab *)
    (onNonEmpty dptr 10, liftGen2 MLab (elems_ Z0 dptr) genRegPtr);
    (* PutLab *)
    (10, liftGen2 PutLab gen_label genRegPtr);
    (* BCall *)
    (10 * onNonEmpty cptr 1 * onNonEmpty lab 1,
     liftGen3 BCall (elems_ Z0 cptr) (elems_ Z0 lab) genRegPtr);
    (* BRet *)
    (if negb (emptyList (unStack stk)) then 50 else 0, pure BRet);
    (* Alloc *)
    (200 * onNonEmpty num 1 * onNonEmpty lab 1,
     liftGen3 Alloc (elems_ Z0 num) (elems_ Z0 lab) genRegPtr);
    (* Load *)
    (onNonEmpty dptr 10, liftGen2 Load (elems_ Z0 dptr) genRegPtr);
    (* Store *)
    (onNonEmpty dptr 100, liftGen2 Store (elems_ Z0 dptr) genRegPtr);
    (* Write *)
    (onNonEmpty dptr 100, liftGen2 Write (elems_ Z0 dptr) genRegPtr);
    (* Jump *)
    (onNonEmpty cptr 10, liftGen Jump (elems_ Z0 cptr));
    (* BNZ *)
    (onNonEmpty num 10,
      liftGen2 BNZ (choose (Zminus (0%Z) (1%Z), 2%Z))
                   (elems_ Z0 num));
    (* PSetOff *)
    (10 * onNonEmpty dptr 1 * onNonEmpty num 1,
     liftGen3 PSetOff (elems_ Z0 dptr) (elems_ Z0 num) genRegPtr);
    (* Put *)
    (10, liftGen2 Put arbitrary genRegPtr);
    (* BinOp *)
    (onNonEmpty num 10,
     liftGen4 BinOp gen_BinOpT (elems_ Z0 num)
              (elems_ Z0 num) genRegPtr);
    (* MSize *)
    (onNonEmpty dptr 10, liftGen2 MSize (elems_ Z0 dptr) genRegPtr);
    (* PGetOff *)
    (onNonEmpty dptr 10, liftGen2 PGetOff (elems_ Z0 dptr) genRegPtr);
    (* Mov *)
    (10, liftGen2 Mov genRegPtr genRegPtr)
].

Definition instantiate_instructions st : G SState :=
  let '(St im m s r pc) := st in
  bindGen (ainstrSSNI st) (fun instr =>
  let im' := nseq (List.length im) instr in
  returnGen (St im' m s r pc)).

(* ------------------------------------------------------ *)
(* -------- Variations ----- ---------------------------- *)
(* ------------------------------------------------------ *)

Class SmartVary (A : Type) := {
  smart_vary : Label -> Info -> A -> G A
}.

(* This generator assumes that even if the label of the
   Atoms is higher that the observablility level then their values
   have to be of the same constructor. However this is not implied
   by indistAtom *)
(* Definition gen_vary_atom (obs: Label) (inf : Info) (a : Atom)  *)
(* : G Atom :=  *)
(*   let '(v @ l) := a in *)
(*   if flows l obs then returnGen a *)
(*   else  *)
(*     match v with *)
(*       | Vint  _ => liftGen2 Atm (liftGen Vint  arbitrary) (pure l) *)
(*       | Vptr  p =>  *)
(*         liftGen2 Atm (liftGen Vptr (smart_gen inf)) (pure l) *)
(*       | Vcptr c =>  *)
(*         liftGen2 Atm (liftGen Vcptr (gen_from_length (code_len inf))) (pure l) *)
(*       | Vlab  _ => *)
(*         liftGen2 Atm (liftGen Vlab (smart_gen inf)) (pure l) *)
(*     end. *)

(* LL: It might be the case that the values don't *have* to be of the same
   constructor, but to get fewer discards it is worth it to keep instructions
   "valid". I agree however that we need to *keep* the chance that something
   is changed. *)

Definition gen_vary_atom (obs: Label) (inf : Info) (a : Atom) : G Atom :=
  let '(v @ l) := a in
  if flows l obs then returnGen a
  else
    freq_ (returnGen a)
      [:: (1, bindGen (gen_value inf) (fun v => returnGen (v @ l)))
      ;(9, match v with
             | Vint  _ =>
               liftGen2 Atm (liftGen Vint (smart_gen inf)) (pure l)
             | Vptr  p =>
               liftGen2 Atm (liftGen Vptr (smart_gen inf)) (pure l)
             | Vlab  _ =>
               liftGen2 Atm (liftGen Vlab (smart_gen inf)) (pure l)
           end)
       ].

Instance smart_vary_atom : SmartVary Atom :=
{|
  smart_vary := gen_vary_atom
|}.

(* Vary a pc. If the pc is high, then it can vary - but stay high! *)

Definition gen_vary_pc (obs: Label) (inf : Info) (pc : Ptr_atom)
: G Ptr_atom :=
  let '(PAtm addr lpc) := pc in
  if isLow lpc obs then pure pc
  else
    bindGen (gen_from_length (code_len inf)) (fun pcPtr =>
    bindGen (gen_high_label obs) (fun pcLab =>
    returnGen (PAtm pcPtr pcLab))).

(* This generator fails to generate PCs with label higher that the observability
   level and lower than pc's label *)

(* Definition gen_vary_pc (obs: Label) (inf : Info) (pc : Ptr_atom) *)
(* : G Ptr_atom := *)
(*   let '(PAtm addr lpc) := pc in *)
(*   if isLow lpc obs then pure pc *)
(*   else *)
(*     bindGen (smart_gen inf) (fun pc' => *)
(*     let '(PAtm addr' lpc') := pc' in *)
(*     returnGen (PAtm addr' (lpc' ∪ lpc))). *)

Instance smart_vary_pc : SmartVary Ptr_atom :=
{|
  smart_vary := gen_vary_pc
|}.


(* Vary a single memory frame :
   - stamp is high -> vary the label and arbitrary data
   - stamp is low
      + stamp join label is high -> arbitrary data
      + stamp join label is low -> vary data

  @Catalin: Should we ever vary stamps?
*)

Definition gen_var_frame (obs: Label) (inf : Info) (f : frame)
: G frame :=
    let '(Fr lab data) := f in
    let gen_length :=
        choose (List.length data, S (List.length data)) in
    let gen_data :=
        bindGen gen_length (fun len => vectorOf len (smart_gen inf)) in
    if isHigh lab obs then
      (* CH: Can't understand the need for this case *)
      (* This is exactly the same as checking for isHigh lab obs*)
      bindGen gen_data (fun data' => returnGen (Fr lab data'))
    else
      bindGen (sequenceGen (map (smart_vary obs inf) data))
              (fun data' => returnGen (Fr lab data')).

Instance smart_vary_frame : SmartVary frame :=
{|
  smart_vary := gen_var_frame
|}.

(* Helper. Takes a single mframe pointer and a memory, and varies the
   corresponding frame *)
Definition handle_single_mframe obs inf (m : memory) (mf : mframe)
: G memory :=
  match get_memframe m mf with
    | Some f =>
      bindGen (smart_vary obs inf f) (fun f' =>
      match upd_memframe m mf f' with
        | Some m' => returnGen m'
        | None    => returnGen m
      end)
    | None => returnGen m
  end.

Fixpoint foldGen {A B : Type} (f : A -> B -> G A) (l : list B) (a : A)
: G A := nosimpl(
  match l with
    | [::] => returnGen a
    | (x :: xs) => bindGen (f a x) (foldGen f xs)
  end).

Definition gen_vary_memory  obs inf (m : memory)
: G memory :=
  let all_mframes := get_blocks all_labels m in
  foldGen (handle_single_mframe obs inf) all_mframes m.

(* Vary memory *)
Instance smart_vary_memory : SmartVary memory :=
{|
  smart_vary := gen_vary_memory
|}.

(* A variation of gen_vary_stack_loc where pc, lab and r vary
   when pc is high *)

(*  Definition gen_vary_stack_loc (obs: Label) (inf : Info)  *)
(*            (s : Ptr_atom * Label * regSet * regId)  *)
(* : G  (Ptr_atom * Label * regSet * regId) := *)
(*     let '(pc, lab, rs, r) := s in *)
(*     (* If the return label is low just vary the registers (a bit) *) *)
(*     if isLow ∂pc obs then  *)
(*       bindGen (sequenceGen (map (smart_vary obs inf) rs)) (fun rs' => *)
(*       returnGen (pc, lab, rs', r)) *)
(*     else  *)
(*     (* Return label is high, create new register file *) *)
(*     (* ZP: Why not vary pc, lab and r? *) *)
(*       bindGen (vectorOf (no_regs inf) (smart_gen inf)) (fun rs' => *)
(*       bindGen (smart_vary obs inf pc) (fun pc' => *)
(*       bindGen (smart_gen inf) (fun lab' => *)
(*       bindGen (gen_from_nat_length (no_regs inf)) (fun r' => *)
(*       returnGen (pc', lab', rs', r'))))). *)

(*
Definition stackFrameBelow (lab : Label) (sf : StackFrame) : bool :=
  let 'SF ret_addr  _ _ _ := sf in
  let 'PAtm _ l_ret_addr := ret_addr in
  flows l_ret_addr lab.

Definition filterStack (lab : Label) (s : Stack) : list StackFrame :=
  (List.filter (stackFrameBelow lab) (unStack s)).

Instance indistStack : Indist Stack :=
{|
  indist lab s1 s2 :=
    indist lab (filterStack lab s1) (filterStack lab s2)
|}.
*)
Definition gen_vary_stack_loc (obs: Label) (inf : Info)
           (s : StackFrame)
: G StackFrame :=
    let '(SF pc rs r lab) := s in
    (* If the return label is low just vary the registers (a bit) *)
    if isLow ∂pc obs then
      bindGen (sequenceGen (map (smart_vary obs inf) rs)) (fun rs' =>
      returnGen (SF pc rs' r lab ))
    else
      bindGen (vectorOf (no_regs inf) (smart_gen inf)) (fun rs' =>
      bindGen (smart_vary obs inf pc) (fun pc' =>
      bindGen (smart_gen inf) (fun lab' =>
      bindGen (gen_from_nat_length (no_regs inf)) (fun r' =>
      returnGen (SF pc' rs' r' lab'))))).

Definition gen_vary_low_stack (obs : Label) (inf : Info) (s : list StackFrame)
: G (list StackFrame) :=
  sequenceGen (map (gen_vary_stack_loc obs inf) s).

Definition gen_vary_stack (obs : Label) (inf : Info) (s : Stack)
: G Stack :=
 liftGen ST (gen_vary_low_stack obs inf (unStack s)).

Instance smart_vary_stack : SmartVary Stack :=
{|
  smart_vary := gen_vary_stack
|}.

Definition gen_vary_SState (obs: Label) (inf : Info) (st: SState) : G SState :=
    let '(St im μ s r pc) := st in
    if isLow ∂pc obs then
      (* PC is low *)
      bindGen (sequenceGen (map (smart_vary obs inf) r)) (fun r' =>
      bindGen (smart_vary obs inf μ) (fun μ' =>
      bindGen (smart_vary obs inf s) (fun s' =>
      returnGen (St im μ' s' r' pc))))
    else
      (* PC is high *)
      bindGen (smart_vary obs inf pc) (fun pc' =>
      (* Memory varies the same way *)
      bindGen (smart_vary obs inf μ) (fun μ' =>
      (* Stack varies the same way at first *)
      bindGen (smart_vary obs inf s) (fun s' =>
      (* Recreate registers *)
      bindGen (vectorOf (no_regs inf) (smart_gen inf)) (fun r' =>
      returnGen (St im μ' s' r' pc'))))).


(* Make sure you create an extra stack loc if pc is high *)
Instance smart_vary_SState : SmartVary SState :=
  {|
    smart_vary := gen_vary_SState
  |}.

(* ------------------------------------------------------ *)
(* -------- Final generation ---------------------------- *)
(* ------------------------------------------------------ *)

(* Generation and population of memory. Doesn't need to use the constants? *)
(*
Instance smart_gen_memory : SmartGen memory :=
{|
  smart_gen inf :=
    let '(MkInfo _ cl _ prins) := inf in


    if Z_eq df1 1%Z && Z_eq df2 2%Z then
    let (_, mI) := extend empty (CFR (replicate cfrSize Nop)) in
    bindGen (genLabel prins) (fun dfrLab1 =>
    bindGen (vectorOf dfrSize1 (genAtom prins cfs dfs)) (fun data1 =>
    let (_, mM) := extend mI (DFR data1 dfrLab1) in
    bindGen (genLabel prins) (fun dfrLab2 =>
    bindGen (vectorOf dfrSize2 (genAtom prins cfs dfs)) (fun data2 =>
    let (_, m) := extend mM (DFR data2 dfrLab2) in
    returnGen m))))
  else Property.trace "Fix Constants" (returnGen empty).
*)

(*
Definition gen_top : G Label :=
  bindGen (choose (C.min_no_prins,
                      C.max_no_prins)) (fun no_prins =>
  returnGen (label_of_list (map Z.of_nat (seq 1 no_prins)))).
*)

(* Generates a memory adhering to the above constants *)
(* Stamps are bottom everywhere - to be created later *)

Fixpoint gen_init_mem_helper (n : nat) (ml : memory * list (mframe * Z)) :=
  match n with
    | O    => returnGen ml
    | S n' =>
      let (m, l) := ml in
      bindGen (choose (C.min_frame_size,
                       C.max_frame_size)) (fun frame_size =>
      bindGen gen_label (fun lab =>
         match (alloc frame_size lab bot (Vint Z0 @ bot) m) with
           | Some (mf, m') =>
             gen_init_mem_helper n' (m', (mf,frame_size) :: l)
           | None => gen_init_mem_helper n' ml
         end))
  end.

Definition gen_init_mem : G (memory * list (mframe * Z)):=
  bindGen (choose (C.min_no_frames,
                      C.max_no_frames)) (fun no_frames =>
  gen_init_mem_helper no_frames (Memory.empty Atom, [::])).

Definition failed_SState : SState :=
  (* Property.trace "Failed SState!" *)
                 (St [::] (Memory.empty Atom) (ST [::]) [::] (PAtm Z0 bot)).

Definition populate_frame inf (m : memory) (mf : mframe) : G memory :=
  match get_memframe m mf with
    | Some (Fr lab data) =>
      bindGen (vectorOf (List.length data) (smart_gen inf)) (fun data' =>
      match upd_memframe m mf (Fr lab data') with
        | Some m' => returnGen m'
        | _ => pure m
      end)
    | _ => pure m
  end.

Definition populate_memory inf (m : memory) : G memory :=
  (* Isn't this supposed to be exactly what is store in Info's data_len field?*)
  (* let all_frames := Mem.get_all_blocks (top_prin inf) m in *)
  let all_frames := [seq fst p | p <- data_len inf] in
  foldGen (populate_frame inf) all_frames m.

(* FIX this to instantiate stamps to a non-trivially well-formed SState *)
Definition instantiate_stamps (st : SState) : SState := st.

Definition get_blocks_and_sizes (m : memory) :=
  map
    (fun b =>
    let length :=
        match get_memframe m b with
          | Some fr =>
            let 'Fr _ data := fr in List.length data
          | _ => 0
        end in (b, Z.of_nat length)) (get_blocks all_labels m).

(* Generate an initial SState.
   TODO : Currently stamps are trivially well formed (all bottom) *)
Definition gen_variation_SState : G (@Variation SState) :=
  (* Generate basic machine *)
  (* Generate initial memory and dfs *)
  bindGen gen_init_mem (fun init_mem_info =>
  let (init_mem, dfs) := init_mem_info in
  (* Generate initial instruction list *)
  let imem := nseq (C.code_len) Nop in
  (* Create initial info - if this fails, fail the generation *)
  match dfs with
    | (def, _) :: _ =>
      let inf := MkInfo def (Z.of_nat C.code_len) dfs C.no_registers in
      (* Generate pc, registers and stack - all pointer stamps are bottom *)
      bindGen (smart_gen inf) (fun pc =>
      bindGen (smart_gen inf) (fun regs =>
      bindGen (smart_gen_stack inf) (fun stk =>
      (* Populate the memory - still all stamps are bottom *)
      bindGen (populate_memory inf init_mem) (fun m =>
      (* Instantiate instructions *)
      let st := St imem m stk regs pc in
      bindGen (instantiate_instructions st) (fun st =>
      (* Instantiate stamps *)
      let st := instantiate_stamps st in
      (* Create Variation *)
      (* bindGen (gen_label_between_lax (get_stack_label stk) prins) (fun obs => *)
      bindGen (gen_label_between_lax bot top) (fun obs =>
      bindGen (smart_vary obs inf st) (fun st' =>
      returnGen (Var obs st st'))))))))
    | _ => returnGen (Var bot failed_SState failed_SState)
  end).

Instance genBinOpT : Gen BinOpT :=
{|
  arbitrary := @gen_BinOpT;
|}.

Instance shrBinOpT : Shrink BinOpT :=
{|
  shrink o  := match o with
               | BAdd => [::]
               | _ => [:: BAdd]
               end
|}.



(* Arbitrary version *)

Derive GenSized for Instr.
Derive GenSized for Pointer.
Derive GenSized for Value.
Derive GenSized for Atom.
Derive GenSized for Ptr_atom.
Derive GenSized for StackFrame.
Derive GenSized for Stack.
Derive GenSized for SState.
Derive GenSized for Variation.



 (* Todo:@akeles *)
Definition gen_variation_copy : G (@Variation SState) :=
  bindGen arbitrary (fun l  =>
  bindGen arbitrary (fun st => 
  returnGen (Var l st st))).


Definition test_propSSNI_smart :=
  forAll gen_variation_SState (fun v =>
    propSSNI_smart default_table v
  ).
  
(*! QuickChick test_propSSNI_smart.  *)

