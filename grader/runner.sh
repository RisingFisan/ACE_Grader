#!/bin/sh

# Run the grader
waitress-serve --port=$PORT grader:app