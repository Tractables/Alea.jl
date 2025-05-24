from benchtool.BenchTool import BenchTool, Entry
from benchtool.Types import Config, LogLevel, ReplaceLevel, TrialArgs

import json
import os
import re
import subprocess
import ctypes
import platform

IMPL_DIR = 'Src'
STRATEGIES_DIR = 'Strategies'
RUNNERS_DIR = 'Runners'
SPEC_PATH = 'Src/Spec.v'


class Coq(BenchTool):

    def __init__(self,
                 results: str,
                 log_level: LogLevel = LogLevel.INFO,
                 replace_level: ReplaceLevel = ReplaceLevel.REPLACE):
        super().__init__(
            Config(start='(*',
                   end='*)',
                   ext='.v',
                   path='workloads/Coq',
                   ignore='common',
                   strategies=STRATEGIES_DIR,
                   impl_path=IMPL_DIR,
                   spec_path=SPEC_PATH), results, log_level, replace_level)

    def all_properties(self, workload: Entry) -> set[str]:
        spec = os.path.join(workload.path, SPEC_PATH)
        with open(spec) as f:
            contents = f.read()
            regex = re.compile(r'prop_[^\s]*')
            matches = regex.findall(contents)
            return list(dict.fromkeys(matches))

    def _build(self, workload_path: str):
        print(f"Building {workload_path}")
        strategies = self._get_generator_names(workload_path)
        strategy_build_commands = map(lambda strategy: self._get_strategy_build_command(strategy),
                                      strategies)
        fuzzers = self._get_fuzzer_names(workload_path)
        fuzzer_build_commands = map(lambda fuzzer: self._get_fuzzer_build_command(fuzzer), fuzzers)
        with self._change_dir(workload_path):
            self._shell_command(['make', 'clean'])
            self._shell_command(['coq_makefile', '-f', '_CoqProject', '-o', 'Makefile'])
            self._shell_command(['make', 'clean'])
            self._shell_command(['make'])

            for cmd in strategy_build_commands:
                self._shell_command(cmd.split(" "))
                self._log(f"Built strategy {cmd}", LogLevel.DEBUG)

            for i, fuzzer_build_command in enumerate(fuzzer_build_commands):
                self._log(f"Built fuzzer {fuzzers[i]}", LogLevel.DEBUG)
                self._log(f"Fuzzer Command 1: {fuzzer_build_command[0]}", LogLevel.DEBUG)
                self._log(f"Fuzzer Command 2: {fuzzer_build_command[1]}", LogLevel.DEBUG)
                self._generate_extended_version_of_fuzzer(fuzzers[i])
                self._shell_command(fuzzer_build_command[2].split(" "))
                self._shell_command(fuzzer_build_command[3].split(" "))
                self._shell_command(fuzzer_build_command[0].split(" "))
                self._shell_command(fuzzer_build_command[1].split(" "))

    def _run_trial(self, workload_path: str, params: TrialArgs):
        self._log(f"Running trial {params}", LogLevel.DEBUG)
        if "Fuzzer" in params.strategy:
            self._run_trial_fuzzer(workload_path, params)
        else:
            self._run_trial_strategy(workload_path, params)

    def _run_trial_fuzzer(self, workload_path: str, params: TrialArgs):
        with self._change_dir(workload_path):
            cmd = ['./main_exec', f'./qc_exec {params.property}']
            results = []
            self._log(
                f"Running {params.workload},{params.strategy},{params.mutant},{params.property}",
                LogLevel.INFO)
            for _ in range(params.trials):
                try:
                    trial_result = {
                        "workload": params.workload,
                        "discards": None,
                        "foundbug": None,
                        "strategy": params.strategy,
                        "mutant": params.mutant,
                        "passed": None,
                        "property": params.property,
                        "time": None
                    }
                    process = subprocess.Popen(
                        cmd,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                        text=True
                    )
                    stdout_data, stderr_data = process.communicate(timeout=params.timeout)
                    start = stdout_data.find("[|")
                    end = stdout_data.find("|]")

                    if start == -1 or end == -1:
                        self._log(f"Unexpected! Error Processing {params.strategy} Output:",
                                  LogLevel.ERROR)
                        self._log(f"[{stdout_data}]", LogLevel.ERROR)
                        self._log(f"[{stderr_data}]", LogLevel.ERROR)
                        trial_result["foundbug"] = False
                        trial_result["discards"] = 0
                        trial_result["passed"] = 0
                        trial_result["time"] = -1
                    else:
                        result = stdout_data[start + 2:end]
                        self._log(f"{params.strategy} Result: {result}", LogLevel.INFO)
                        json_result = json.loads(result)
                        trial_result["foundbug"] = json_result["result"] in [
                            "failed", "expected_failure"
                        ]
                        trial_result["discards"] = json_result["discards"]
                        trial_result["passed"] = json_result["tests"]
                        trial_result["time"] = float(
                            json_result["time"]
                            [:-2]) * 0.001  # ms as string to seconds as float conversion

                except subprocess.TimeoutExpired as e:
                    print(f"Process Timed Out {process.pid}")
                    os.system(f"pkill qc_exec")
                    print(f"Process Output: {e}")
                    shm_id = int(e.stdout.decode("utf-8").split("|?SHM ID: ")[1].split("?|")[0])
                    print(f"Shared Memory ID: {shm_id}")
                    # Libc is platform dependent, so we need to load it dynamically
                    if platform.system() == "Darwin":
                        libc = ctypes.CDLL("/usr/lib/libc.dylib")
                    elif platform.system() == "Linux":
                        libc = ctypes.CDLL("libc.so.6")

                    self._log(f"Releasing Shared Memory: {libc.shmctl(int(shm_id), 0, 0)}",
                              LogLevel.INFO)
                    self._log(f"Released Shared Memory with ID: {shm_id}", LogLevel.INFO)
                    trial_result["foundbug"] = False
                    trial_result["discards"] = 0
                    trial_result["passed"] = 0
                    trial_result["time"] = params.timeout
                    self._log(f"{params.strategy} Result: Timeout", LogLevel.INFO)

                except subprocess.CalledProcessError as e:
                    self._log(f"Error Running {params.strategy}:", LogLevel.ERROR)
                    self._log(f"[{e.stdout}]", LogLevel.ERROR)
                    self._log(f"[{e.stderr}]", LogLevel.ERROR)
                    trial_result["foundbug"] = False
                    trial_result["discards"] = 0
                    trial_result["passed"] = 0
                    trial_result["time"] = -1

                results.append(trial_result)
                if params.short_circuit and trial_result['time'] == params.timeout:
                    break
                elif trial_result['time'] == -1:
                    self._log(f"Exiting due to erroneous trial", LogLevel.ERROR)
                    exit(0)

            json.dump(results, open(params.file, 'w'))

    def _run_trial_strategy(self, workload_path: str, params: TrialArgs):
        with self._change_dir(workload_path):
            cmd = [f"./{params.strategy}_test_runner.native", params.property]
            results = []
            self._log(
                f"Running {params.workload},{params.strategy},{params.mutant},{params.property}",
                LogLevel.INFO)
            for _ in range(params.trials):
                trial_result = {
                    "workload": params.workload,
                    "discards": None,
                    "foundbug": None,
                    "strategy": params.strategy,
                    "mutant": params.mutant,
                    "passed": None,
                    "property": params.property,
                    "time": None
                }
                try:
                    process = subprocess.Popen(
                        cmd,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                        text=True
                    )

                    stdout_data, stderr_data = process.communicate(timeout=params.timeout)

                    start = stdout_data.find("[|")
                    end = stdout_data.find("|]")
                    result = stdout_data[start + 2:end]
                    self._log(f"{params.strategy} Result: {result}", LogLevel.INFO)
                    # print("stdout===")
                    # print(stdout_data)
                    # print("stderr===")
                    # print(stderr_data)
                    # print("result===")
                    # print(result)
                    json_result = json.loads(result)
                    trial_result["foundbug"] = json_result["result"] in [
                        "failed", "expected_failure"
                    ]
                    trial_result["discards"] = json_result["discards"]
                    trial_result["passed"] = json_result["tests"]
                    trial_result["time"] = float(
                        json_result["time"]
                        [:-2]) * 0.001  # ms as string to seconds as float conversion

                except subprocess.TimeoutExpired:
                    process.kill()

                    trial_result["foundbug"] = False
                    trial_result["discards"] = 0
                    trial_result["passed"] = 0
                    trial_result["time"] = params.timeout
                    self._log(f"{params.strategy} Result: Timeout", LogLevel.INFO)

                results.append(trial_result)
                failures = sum(1 for result in results if not result["foundbug"])
                if failures * 2 > params.trials:
                    break

                if params.short_circuit and trial_result['time'] == params.timeout:
                    break

            json.dump(results, open(params.file, 'w'))

    def _generate_extended_version_of_fuzzer(self, fuzzer: str):
        fuzzer_path = f"./{fuzzer}_test_runner.ml"
        extended_fuzzer_path = f"./{fuzzer}_test_runner_ext.ml"
        stub_path = f"{os.environ['OPAM_SWITCH_PREFIX']}/lib/coq/user-contrib/QuickChick/Stub.ml"
        f = open(extended_fuzzer_path, "w+")
        with open(stub_path, "r") as stub:
            f.write(stub.read())
            f.write("\n\n(* -----(Stub Ends)----- *)\n\n")
        with open(fuzzer_path, "r") as fuzzer_file:
            f.write(fuzzer_file.read())
        f.close()

    def _get_executable_strategy_names(self, workload_path):
        strategies_path = f"{workload_path}/{STRATEGIES_DIR}"
        strategies = self._get_strategy_names(strategies_path)
        executables = list(map(lambda strategy: f"{strategy}_test_runner.native", strategies))
        return executables

    def _get_strategy_build_command(self, strategy: str) -> str:
        self._log(f"Building strategy: {strategy}", LogLevel.INFO)
        return f"ocamlfind ocamlopt -linkpkg -package zarith -package unix -rectypes {strategy}_test_runner.mli {strategy}_test_runner.ml -o {strategy}_test_runner.native"

    def _get_fuzzer_build_command(self, fuzzer: str) -> str:
        qc_path = os.environ['OPAM_SWITCH_PREFIX'] + '/lib/coq/user-contrib/QuickChick'
        fuzzer_build_command = (
            f"ocamlfind ocamlopt -ccopt -Wno-error=implicit-function-declaration -afl-instrument -linkpkg -package unix -package str -package coq-core.plugins.extraction -thread -rectypes -w a -o ./qc_exec ./{fuzzer}_test_runner_ext.ml {qc_path}/SHM.c",
            f"ocamlfind ocamlopt -ccopt -Wno-error=implicit-function-declaration -linkpkg -package unix -package str -rectypes -w a -I . -o main_exec {qc_path}/Main.ml {qc_path}/SHM.c",
            f"{qc_path}/cmdprefix.pl {fuzzer}_test_runner_ext.ml",
            f"{qc_path}/cmdsuffix.pl {fuzzer}_test_runner_ext.ml")

        return fuzzer_build_command

    def _get_fuzzer_names(self, workload_path):
        fuzzers = list(
            filter(lambda f: f.endswith("Fuzzer"),
                   self._get_all_strategy_names(f"{workload_path}/{STRATEGIES_DIR}")))
        return fuzzers

    def _get_generator_names(self, workload_path):
        generators = list(
            filter(lambda f: f.endswith("Generator"),
                   self._get_all_strategy_names(f"{workload_path}/{STRATEGIES_DIR}")))
        return generators

    def _get_all_strategy_names(self, strategies_path) -> list[str]:
        strategies = []
        for strategy in os.listdir(strategies_path):
            f = os.path.join(strategies_path, strategy)
            if os.path.isfile(f) and f.endswith(".v"):
                strategies.append(strategy[:-2])
        return strategies

    def _parse_tests_qc(self, s: str) -> tuple[list, str]:
        return self._parse_tests("QuickChick", s)

    def _parse_tests_fc(self, s: str) -> tuple[list, str]:
        return self._parse_tests("FuzzChick", s)

    def _parse_tests(self, vernacular: str, s: str) -> tuple[list, str]:

        def compile(s: str) -> re.Pattern:
            return re.compile(s, flags=re.DOTALL)

        start = re.escape(self._config.start)
        end = re.escape(self._config.end)

        test_re = compile(fr"{start}!\s*{vernacular}\s*(\w+).*?{end}")
        test_ls = re.findall(test_re, s)
        return test_ls

    def _generate_test_file_qc(self, runners_path: str, strategy_name: str, tests: list[str],
                               workload: Entry):
        workload_name = workload.name
        file_name = f"{strategy_name}_test_runner.v"
        strategy_import = f"From {workload_name} Require Import {strategy_name}.\n"
        library_import = "From QuickChick Require Import QuickChick.\n"
        set_warnings = 'Set Warnings "-extraction-opaque-accessed,-extraction".\n'
        size_axiom = 'Axiom num_tests : nat. Extract Constant num_tests => "max_int".\n'
        test_string_template = "Definition qctest_<test-name> := (fun _ : unit => print_extracted_coq_string (\"[|{\" ++ show (withTime(fun tt => (quickCheckWith (updMaxDiscard (updMaxSuccess (updAnalysis stdArgs true) num_tests) num_tests) <test-name>))) ++ \"}|]\")).\n"
        test_map = f"""

Parameter OCamlString : Type.
Extract Constant OCamlString => "string".
Axiom qctest_map : OCamlString -> unit.
Extract Constant qctest_map => "
fun test_name ->
  let test_map = [
    {'; '.join([f'(""{test_name}"", qctest_{test_name})' for test_name in tests])}
  ] in
  let test = List.assoc test_name test_map in
  test ()


let () =
  Sys.argv.(1) |> qctest_map
".

"""
        extraction_string_template = f'Extraction "{strategy_name}_test_runner.ml" <test-names> qctest_map.\n'

        with open(os.path.join(runners_path, file_name), "w") as runner_file:
            runner_file.write(strategy_import)
            runner_file.write(library_import)
            runner_file.write(set_warnings)
            runner_file.write(size_axiom)
            for test in tests:
                test_string = test_string_template.replace("<test-name>", test)
                runner_file.write(test_string)
            test_names = " ".join(list(map(lambda test: f"qctest_{test}", tests)))
            runner_file.write(test_map)
            extraction_string = extraction_string_template.replace("<test-names>", test_names)
            runner_file.write(extraction_string)

    def _generate_test_file_fc(self, runners_path: str, fuzzer_name: str, tests: list[str],
                               workload: Entry):
        workload_name = workload.name
        file_name = f"{fuzzer_name}_test_runner.v"
        strategy_import = f"From {workload_name} Require Import {fuzzer_name}.\n"
        library_import = "From QuickChick Require Import QuickChick.\n"
        set_warnings = 'Set Warnings "-extraction-opaque-accessed,-extraction".\n'
        test_string_template = "Definition qctest_<test-name> := (fun _ : unit => print_extracted_coq_string (\"[|{\" ++ show (withTime (fun tt => (<test-name>_fuzzer tt))) ++ \"}|]\")).\n"
        test_map = f"""

Parameter OCamlString : Type.
Extract Constant OCamlString => "string".
Axiom qctest_map : OCamlString -> unit.
Extract Constant qctest_map => "
fun test_name ->
  let test_map = [
    {'; '.join([f'(""{test_name}"", qctest_{test_name})' for test_name in tests])}
  ] in
  let test = List.assoc test_name test_map in
  test ()


let () =
  Printf.printf ""Entering main of qc_exec\\n""; flush stdout;
  setup_shm_aux ();
  Sys.argv.(1) |> qctest_map ; flush stdout;
".

"""
        extraction_string_template = f'Extraction "{fuzzer_name}_test_runner.ml" <test-names> qctest_map.'

        with open(os.path.join(runners_path, file_name), "w") as runner_file:
            runner_file.write(strategy_import)
            runner_file.write(library_import)
            runner_file.write(set_warnings)
            for test in tests:
                test_string = test_string_template.replace("<test-name>", test)
                runner_file.write(test_string)
            test_names = " ".join(list(map(lambda test: f"qctest_{test}", tests)))
            runner_file.write(test_map)
            extraction_string = extraction_string_template.replace("<test-names>", test_names)
            runner_file.write(extraction_string)

    def _preprocess(self, workload: Entry) -> None:
        # Relevant Paths
        strategies_path = f"{workload.path}/{STRATEGIES_DIR}/"
        runners_path = f"{workload.path}/{RUNNERS_DIR}/"
        # Generate runner files
        generators = self._get_generator_names(workload.path)
        fuzzers = self._get_fuzzer_names(workload.path)
        # Empty Runner Directory
        self._shell_command(['rm', f"{runners_path}*"])
        # Generate and Add Runners for each strategy
        for strategy in generators:
            with open(os.path.join(strategies_path, f"{strategy}.v"), "r") as strategy_file:
                content = strategy_file.read()
                tests = self._parse_tests_qc(content)
                self._generate_test_file_qc(runners_path, strategy, tests, workload)
        # Generate and Add Runners for each fuzzer
        for fuzzer in fuzzers:
            with open(os.path.join(strategies_path, f"{fuzzer}.v"), "r") as strategy_file:
                content = strategy_file.read()
                tests = self._parse_tests_fc(content)
                self._generate_test_file_fc(runners_path, fuzzer, tests, workload)
        # Add runners to the _CoqProject file
        with open(f"{workload.path}/_CoqProject", "r") as coq_project_file_reader:
            coq_project_file_contents = coq_project_file_reader.read().splitlines()

        print(generators)
        with open(f"{workload.path}/_CoqProject", "w") as coq_project_file_writer:
            print("==========")
            print(coq_project_file_contents)

            l = ""
            for coq_project_file_line in coq_project_file_contents:
                if (
                    not coq_project_file_line.startswith(RUNNERS_DIR)
                    and not coq_project_file_line.startswith(STRATEGIES_DIR)
                    and coq_project_file_line != ""
                ):
                    s = coq_project_file_line + "\n"
                    coq_project_file_writer.write(s)
                    l += s

            for strategy in generators + fuzzers:
                s = f"{STRATEGIES_DIR}/{strategy}.v\n"
                l += s
                coq_project_file_writer.write(s)
            for strategy in generators + fuzzers:
                s = f"{RUNNERS_DIR}/{strategy}_test_runner.v\n"
                l += s
                coq_project_file_writer.write(s)
            print(l)
