import os
from datetime import datetime
from typing import Any, Callable, TypeVar

from benchtool.Types import Entry, LogLevel

T = TypeVar('T')
U = TypeVar('U')


def list_map(f: Callable[[T], U], xs: list[T]) -> list[U]:
    return list(map(f, xs))


def concat(xss: list[list[T]]) -> list[T]:
    return [x for xs in xss for x in xs]


def concat_map(f: Callable[[T], list[U]], xss: list[T]) -> list[U]:
    return concat(list_map(f, xss))


def scandir_filter(path: str, f: Any) -> list[Entry]:
    return [Entry(x.name, x.path) for x in os.scandir(path) if f(x) and not x.name.startswith('.')]

def recursive_scandir_filter(path: str, f: Any) -> list[Entry]:
    entries = []
    for entry in os.scandir(path):
        if entry.is_file() and f(entry):
            entries.append(Entry(entry.name, entry.path))
        elif entry.is_dir(follow_symlinks=False):
            entries += recursive_scandir_filter(entry.path, f)
    return entries

class ChangeDir(object):

    def __init__(self, new_dir):
        self.old_dir = None
        self.new_dir = new_dir

    def __enter__(self):
        self.old_dir = os.getcwd()
        if os.path.isabs(self.new_dir):
            new_dir = self.new_dir
        else:
            new_dir = os.path.join(self.old_dir, self.new_dir)
        os.chdir(new_dir)

    def __exit__(self, _a, _b, _c):
        if not self.old_dir:
            raise Exception('impossible')
        os.chdir(self.old_dir)
        return False


def print_log(msg: str, msg_level: LogLevel, log_level: LogLevel):
    if msg_level >= log_level:
        time = datetime.now().strftime('%H:%M:%S')
        print(f'{time} [{msg_level.name}] {msg}')
