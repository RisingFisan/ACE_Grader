# This is a Python script that receives two arguments through argv
# The first one is an executable path, the other is a string
# The script executes the file specified in the path and gives the string as input to the executed program
# The subprocess has a timeout of 5 seconds, and the Python program writes the subprocess' output to stdout

import sys # import the sys module to access argv
import subprocess # import the subprocess module to run commands

# Check if there are exactly two arguments given
if len(sys.argv) == 3:
    # Assign the first argument to a variable called path
    path = sys.argv[1]
    # Assign the second argument to a variable called string
    pinput = sys.argv[2]
    try:
        # Run the command specified by the path with the string as input
        # Capture the output and set a timeout of 5 seconds
        result = subprocess.run([path], input=pinput.encode(), capture_output=True, timeout=5, check=True)
        # Print "SUCCESS" on the first line and the output on the following lines
        print("SUCCESS")
        sys.stdout.write(result.stdout.decode())
    except subprocess.TimeoutExpired as e:
        # Print "TIMEOUT" on the first line if the timeout is reached
        print("TIMEOUT")
    except subprocess.CalledProcessError as e:
        # Print "ERROR" on the first line and the error message on the following lines if there is an error
        print("ERROR")
        sys.stderr.write(e.stderr.decode())
else:
    # Print an error message if there are not exactly two arguments given
    print("Usage: python script.py path input")