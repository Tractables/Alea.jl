import functools
import os
from platform import node
import re
from functools import reduce, partial

from benchtool.Types import (Config, Entry, Mutant, Mutants, Node, Original,
                             Text, Variant)
from benchtool.Util import concat, list_map


class Parser():

    def __init__(self, config: Config):
        self.config = config
        self.start = self.config.start + '!'

    def parse_code(self, s: str) -> tuple[str, str]:
        parts = s.partition(self.start)
        return parts[0], (parts[1] + parts[2])

    def parse_mutants(self, s: str) -> tuple[Mutants, str]:

        def compile(s: str) -> re.Pattern:
            return re.compile(s, flags=re.DOTALL)

        start = re.escape(self.config.start)
        end = re.escape(self.config.end)

        # {-! -}
        # base body
        comment_re = compile(fr"{start}!\s*{end}")
        comment_m = comment_re.match(s)
        if not comment_m:
            raise Exception('No base mutant found')
        s = s[comment_m.end():]
        base, s = self.parse_code(s)

        # {-!! mutant_name -}
        # {-!  mutant body -}
        name_re = fr"{start}!!\s*(?P<name>\w+)\s*{end}"
        body_re = fr"{start}!(?P<body>.*?){end}"

        mutant_re = compile(fr'\s*{name_re}\s*{body_re}')

        # Iterate through consecutive mutants.
        mutants_ls = []

        while True:
            mutant_m = mutant_re.match(s)
            if not mutant_m:
                break

            dict = mutant_m.groupdict()
            mutants_ls.append(Mutant(dict['name'], dict['body']))
            s = s[mutant_m.end():]

        return Mutants(base, mutants_ls), s

    def parse(self, workload: Entry) -> dict[str, list[Node]]:
        impl_path = os.path.join(workload.path, self.config.impl_path)
        paths = list(map(
            lambda filename: os.path.join(impl_path, filename),
            (list(filter(
                # TODO: is this necessary since listdir is not recursive?
                lambda filename: filename.endswith(self.config.ext)
                                and "Runners/" not in filename
                                and "Methods/" not in filename,
                os.listdir(impl_path)
            )))
        ))
        nodes_dict = { path: [] for path in paths }
        for path in paths:
            with open(path) as f:
                s = f.read()

                nodes: list[Node] = []
                while s:
                    # Parse block of mutants.
                    if s.startswith(self.start):
                        mutants, s = self.parse_mutants(s)
                        nodes.append(mutants)
                    # Parse other code.
                    else:
                        code, s = self.parse_code(s)
                        nodes.append(Text(code.rstrip()))
                nodes_dict[path] = nodes
        nodes_dict = dict(filter(
            lambda paths_and_nodes: len(paths_and_nodes[1]) > 1,
            nodes_dict.items()
        ))
        return nodes_dict

    def extract(self, nodes_dict: dict[str, list[Node]]) -> list[Variant]:
        # Each variant should have zero or one mutants spliced in.
        # `append_base` and `append_mutant` vary based on type of `v`.

        def f(path: str, vs: list[Variant], node: Node):
            match node:
                case Text():
                    return list_map(lambda v: v.append_base(path, node.text), vs)
                case Mutants():
                    vs = list_map(lambda v: v.append_mutant(path, node), vs)
                    # Force mutants to be in correct order.
                    vs.append(vs[0][1:])
                    vs[0] = [vs[0][0]]
                    return concat(vs)

        all_variants = []
        for path, nodes in nodes_dict.items():
            variants = [Original(path, '')]
            variants = reduce(partial(f, path), nodes, variants)
            all_variants += variants

        unique_all_variants: list[Variant] = []
        for variant in all_variants:
            if variant.name not in map(lambda v: v.name, unique_all_variants):
                unique_all_variants.append(variant)
        return unique_all_variants