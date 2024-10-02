from enum import Enum
import os
import shutil
import uuid
from datetime import datetime
from threading import RLock

from status import Status
from languages import c, haskell

PATH = '/tmp/ace-grader/'

class Language(Enum):
    C = c
    HASKELL = haskell

class Program:
    def __init__(self, main_content : str, submission_content : str, language : str) -> None:
        self.id : str = str(uuid.uuid4())
        self.main : str = main_content
        self.submission : str = submission_content
        self.compilation = Status.PENDING
        self.created = datetime.now()
        self.lock = RLock()
        match language.lower():
            case "c":
                self.language = Language.C
            case "haskell":
                self.language = Language.HASKELL
            case _:
                raise ValueError(f"Invalid language name '{language}'")

    def get_path(self) -> str:
        return PATH + self.id

    def compile(self) -> tuple[Status, str]:
        with self.lock:
            (status, output) = self.language.value.compile(self)
            self.compilation = status
            return (status, output)

    def test(self, test_input) -> tuple[Status, str]:
        with self.lock:
            (status, output) = self.language.value.test(self, test_input)
            return (status, output)

    def clean(self) -> None:
        with self.lock:
            if os.path.exists(self.get_path()):
                shutil.rmtree(self.get_path())
            
if __name__ == '__main__':
    main = """\
main = do
    putStrLn $ hello_world
"""
    submission = """\
hello_world = "Hello, World!"
"""
    p = Program(main, submission, "haskell")
    (status, output) = p.compile()