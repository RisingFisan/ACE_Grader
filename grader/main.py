from flask import Flask, request, jsonify
import subprocess
import os
import shutil
import time
import threading

from datetime import datetime, timedelta

from analyzer import run_checks
from program import Program, Status

app = Flask(__name__)

programs : list[Program] = []

def add_program(program):
    global programs
    programs.append(program)

def get_program(id):
    global programs
    if not id: return None
    return next((p for p in programs if p.id == id), None)

def clear_expired_programs():
    global programs
    while True:
        time.sleep(60)  # Check every minute
        now = datetime.now()
        expired = set()
        for program in programs:
            if now - program.created >= timedelta(minutes=10):
                program.clean()
                expired.add(program.id)
        programs = list(filter(lambda p: p.id not in expired, programs))

threading.Thread(target=clear_expired_programs, daemon=True).start()

@app.route('/ping', methods=['GET'])
def ping():
    return jsonify('pong')

@app.route('/compile', methods=['POST'])
def compile_code():
    data = request.get_json()

    code = data.get('code')
    test_file = data.get('test_file')
    language = data.get('language')

    program = Program(main_content=test_file, submission_content=code, language=language)

    (status, output) = program.compile()
    match status:
        case Status.SUCCESS:
            add_program(program)
            return jsonify({'status': 'success', 'output': output, 'id': program.id})
        case Status.TIMEOUT:
            program.clean()
            return jsonify({'status': 'timeout'})
        case Status.ERROR:
            program.clean()
            return jsonify({'status': 'error', 'output': output})
    
@app.route('/execute', methods=['POST'])
def execute_program():
    data = request.get_json()

    id = data.get('id')

    test_input = data.get('input', "")

    program = get_program(id)
    if not program:
        return jsonify({'error': 'Program not found, make sure that an ID has been given and that the program has been compiled.'})

    (status, output) = program.test(test_input)

    match status:
        case Status.SUCCESS:
            return jsonify({'status': 'success', 'output': output})
        case Status.TIMEOUT:
            return jsonify({'status': 'timeout'})
        case _:
            return jsonify({'status': 'error', 'output': output})

@app.route('/analyze', methods=['POST'])
def analyze_submission():
    data = request.get_json()
    id = data.get('id')
    params = data.get('params', [])

    match data.get('language').lower():
        case 'c':
            os.chdir(f'/tmp/ace-grader/{id}')
            result = run_checks(params)
            print(result)

            return jsonify(result)
        case _:
            return jsonify({'status': 'error', 'output': 'not supported'})

# def clean(path):
#     if os.path.exists(path):
#         shutil.rmtree(path)

# @app.route('/cleanup', methods=['POST'])
# def cleanup():
#     data = request.get_json()
#     id = data.get('id')
#     path = f'/tmp/{id}'
#     clean(path)
#     return jsonify({'status': 'success'})

if __name__ == '__main__':
    from waitress import serve
    import logging
    logger = logging.getLogger('waitress')
    logger.setLevel(logging.INFO)
    serve(app, host=os.getenv("HOST", '0.0.0.0'), port=int(os.getenv("PORT", '5000')))
