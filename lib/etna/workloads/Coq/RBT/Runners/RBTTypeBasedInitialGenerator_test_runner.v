From RBT Require Import RBTTypeBasedInitialGenerator.
From QuickChick Require Import QuickChick.
Set Warnings "-extraction-opaque-accessed,-extraction".
Axiom num_tests : nat. Extract Constant num_tests => "100_000".
Definition qctest_test_prop_True := (fun _ : unit => print_extracted_coq_string ("[|{" ++ show (withTime(fun tt => (quickCheckWith (updMaxDiscard (updMaxSuccess (updAnalysis stdArgs true) num_tests) num_tests) test_prop_True))) ++ "}|]")).


Parameter OCamlString : Type.
Extract Constant OCamlString => "string".
Axiom qctest_map : OCamlString -> unit.
Extract Constant qctest_map => "
fun _test_name ->
  qctest_test_prop_True () 

let () =
  Sys.argv.(1) |> qctest_map
".

Extraction "RBTTypeBasedInitialGenerator_test_runner.ml" qctest_test_prop_True qctest_map.
