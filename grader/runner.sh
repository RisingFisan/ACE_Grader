#!/bin/sh

# Run the grader
waitress-serve --port=$PORT main:app