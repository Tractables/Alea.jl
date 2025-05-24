from __future__ import annotations

import dataclasses
import json
from abc import ABC, abstractmethod
from dataclasses import dataclass
from enum import IntEnum

FilePath = str


@dataclass
class Config:
    ''' Language-specific configuration. '''

    start: str
    ''' Start of multi-line comment. '''
    end: str
    ''' End of multi-line comment. '''
    ext: str
    ''' File extension. '''

    path: FilePath
    ''' Path to directory containing workloads. '''
    ignore: str
    ''' Directory name to ignore (e.g. contains library code). '''

    strategies: FilePath
    ''' Relative path to directory containing strategies. '''
    impl_path: FilePath
    ''' Relative path to file containing base and mutant implementations. '''
    spec_path: FilePath
    ''' Relative path to file containing properties. '''


class Node:
    ''' A chunk of the file being parsed. '''
    pass


@dataclass
class Text(Node):
    ''' A chunk of contiguous text not containing mutants. '''
    text: str


Tag = str


@dataclass
class Mutant:
    ''' A single mutant. '''

    tag: Tag
    ''' Mutant name. '''
    body: str
    ''' Mutant code. '''


@dataclass
class Mutants(Node):
    '''
    A parsed chunk of continguous text containing
    a base and one or more mutants.
    '''

    base: str
    mutants: list[Mutant]


@dataclass
class Variant(ABC):
    '''
    Either a base or mutant implementation.
    '''
    filename: str
    body: str
    name: str = 'base'

    @abstractmethod
    def append_base(self, path: str, b: str) -> Variant:
        pass

    @abstractmethod
    def append_mutant(self, path: str, ms: Mutants) -> list[Variant]:
        pass


@dataclass
class Original(Variant):

    def append_base(self, path: str, b: str) -> Variant:
        return Original(path, self.body + b)

    def append_mutant(self, path: str, ms: Mutants) -> list[Variant]:
        base = self.append_base(path, ms.base)
        mutants: list[Variant] = [Modified(path, self.body + m.body, m.tag) for m in ms.mutants]
        return [base] + mutants


@dataclass
class Modified(Variant):

    def append_base(self, path: str, b: str) -> Variant:
        return Modified(path, self.body + b, self.name)

    def append_mutant(self, path: str, ms: Mutants) -> list[Variant]:
        return [self.append_base(path, ms.base)]


@dataclass
class Entry:
    '''
    A simpler version of `os.DirEntry` that stores
    both the name of a workload, strategy, etc. and its path.
    '''

    name: str
    path: FilePath


@dataclass
class TrialArgs:
    file: str
    trials: int
    workload: str
    strategy: str
    mutant: str
    property: str
    label: str
    timeout: float | None = None
    short_circuit: bool = False

    def to_json(self) -> str:
        return json.dumps(dataclasses.asdict(self))


@dataclass
class TrialConfig:
    trials: int
    workload: Entry
    strategy: str
    property: str
    file: str | None = None  # if not provided, use default format
    label: str | None = None  # if not provided, use same as strategy
    timeout: float | None = None  # in seconds
    short_circuit: bool = False


class LogLevel(IntEnum):
    DEBUG = 0
    INFO = 1
    WARNING = 2
    ERROR = 3


class ReplaceLevel(IntEnum):
    REPLACE = 0
    ''' Replace existing data with new data. '''
    SKIP = 1
    ''' Skip existing data. '''
    FAIL = 2
    ''' Fail if existing data is found. '''