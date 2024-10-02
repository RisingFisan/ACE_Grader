from contextlib import contextmanager
import os

@contextmanager
def cd(newdir : str):
    prevdir = os.getcwd()
    newdir = os.path.expanduser(newdir)
    if not os.path.exists(newdir):
        os.makedirs(newdir)
    os.chdir(newdir)
    try:
        yield
    finally:
        os.chdir(prevdir)