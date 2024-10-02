import subprocess

from utils import cd
from status import Status

def compile(program):
    with cd(program.get_path()):
        with open('main.c', 'w') as f:
            f.write(program.main)
        with open('sub.c', 'w') as f:
            f.write(program.submission)

        try:
            result = subprocess.run(['gcc', 'main.c', 'sub.c', '-o', 'main', '-Wall'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=5, check=True)
            output = result.stdout.decode()
            return (Status.SUCCESS, output)
        except subprocess.TimeoutExpired:
            return (Status.TIMEOUT, '')
        except subprocess.CalledProcessError as e:
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