import subprocess

from utils import cd
from status import Status

def compile(program):
    with cd(program.get_path()):
        with open("main.hs", "w") as f:
            f.write("import Submission\n\n")
            f.write(program.main)
        with open("sub.hs", "w") as f:
            f.write("module Submission where\n\n")
            f.write(program.submission)

        try:
            result = subprocess.run(['ghc', 'main.hs', 'sub.hs', '-Wall', '-Wno-missing-signatures', '-v0'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=5, check=True)
            # output = '\n'.join(line for line in result.stdout.decode().splitlines() if "of 2]" not in line and "Linking main ..." not in line)
            output = result.stdout.decode()
            return (Status.SUCCESS, output)
        except subprocess.TimeoutExpired:
            return (Status.TIMEOUT, '')
        except subprocess.CalledProcessError as e:
            # output = '\n'.join(line for line in e.stdout.decode().splitlines() if "of 2]" not in line and "Linking main ..." not in line)
            output = e.stdout.decode()
            return (Status.ERROR, output)
        
def test(program, test_input : str):
    with cd(program.get_path()):
        try:
            result = subprocess.run(['./main'], input=test_input.encode(), capture_output=True, timeout=5, check=True)
            output = result.stdout.decode()
            return (Status.SUCCESS, output)
        except subprocess.TimeoutExpired:
            return (Status.TIMEOUT, '')
        except subprocess.CalledProcessError as e:
            output = e.stderr.decode()
            # abs(e.returncode)
            return (Status.ERROR, output)
        except UnicodeDecodeError:
            return (Status.ERROR, 'Output decoding error.')