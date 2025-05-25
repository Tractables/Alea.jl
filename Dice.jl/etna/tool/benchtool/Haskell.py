import os
import re
import json
from benchtool.BenchTool import BenchTool
from benchtool.Types import Config, Entry, LogLevel, ReplaceLevel, TrialArgs


class Haskell(BenchTool):

    def __init__(self,
                 results: str,
                 log_level: LogLevel = LogLevel.INFO,
                 replace_level: ReplaceLevel = ReplaceLevel.REPLACE):
        super().__init__(
            Config(
                start='{-',  # Haskell multi-line comment syntax
                end='-}',
                ext='.hs',
                path='workloads/Haskell',
                ignore='common',  # This contains the library code
                strategies='src/Strategy',
                impl_path='src',
                spec_path='src/Spec.hs'),
            results,
            log_level,
            replace_level)

    def all_properties(self, workload: Entry) -> set[str]:
        spec = os.path.join(workload.path, self._config.spec_path)
        with open(spec) as f:
            contents = f.read()
            regex = re.compile(r'prop_[^\s]*')
            matches = regex.findall(contents)
            return list(dict.fromkeys(matches))

    def _build(self, workload_path: str):
        with self._change_dir(workload_path):
            self._shell_command(['stack', 'build'])

    def _run_trial(self, workload_path: str, params: TrialArgs):

        def reformat():
            # Get JSONs into a format that
            # makes it easier to parse later on.
            with open(params.file) as f:
                results = [json.loads(line) for line in f]
            open('file.txt', 'w').close()
            json.dump(results, open(params.file, 'w'))

        with self._change_dir(workload_path):
            for _ in range(params.trials):
                # Re-run per trial to avoid caching problems.
                p = params.to_json()
                self._shell_command(['stack', 'exec', 'etna-workload', '--', p])

                if params.short_circuit:
                    # Optimization: terminate as soon as a task is not solved
                    # instead of running for the full umber of trials.
                    with open(params.file) as f:
                        if '"foundbug":false' in f.read():
                            reformat()
                            return

        reformat()

    def _preprocess(self, workload: Entry) -> None:
        pass