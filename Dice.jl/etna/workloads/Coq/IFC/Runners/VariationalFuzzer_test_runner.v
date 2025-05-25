From IFC Require Import VariationalFuzzer.
From QuickChick Require Import QuickChick.
Set Warnings "-extraction-opaque-accessed,-extraction".
Definition qctest_test_propSSNI_smart := (fun _ : unit => print_extracted_coq_string ("[|{" ++ show (withTime (fun tt => (test_propSSNI_smart_fuzzer tt))) ++ "}|]")).


Parameter OCamlString : Type.
Extract Constant OCamlString => "string".
Axiom qctest_map : OCamlString -> unit.
Extract Constant qctest_map => "
fun test_name ->
  let test_map = [
    (""test_propSSNI_smart"", qctest_test_propSSNI_smart)
  ] in
  let test = List.assoc test_name test_map in
  test ()


let () =
  Printf.printf ""Entering main of qc_exec\n""; flush stdout;
  setup_shm_aux ();
  Sys.argv.(1) |> qctest_map ; flush stdout;
".

Extraction "VariationalFuzzer_test_runner.ml" qctest_test_propSSNI_smart qctest_map.