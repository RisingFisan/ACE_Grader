from flask import Flask, request, jsonify
import subprocess
import os
import shutil

from analyzer import run_checks

app = Flask(__name__)

@app.route('/compile', methods=['POST'])
def compile_code():
    data = request.get_json()
    id = data.get('id')
    code = data.get('code')
    test_file = data.get('test_file')

    path = f'/tmp/{id}'
    if os.path.exists(path):
        shutil.rmtree(path)
    os.mkdir(path)
    os.chdir(path)

    with open('main.c', 'w') as f:
        f.write(test_file)
    with open('sub.c', 'w') as f:
        f.write(code)

    try:
        result = subprocess.run(['gcc', 'main.c', 'sub.c', '-o', 'main', '-Wall'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=5, check=True)
        return jsonify({'status': 'success', 'output': result.stdout.decode()})
    except subprocess.TimeoutExpired:
        clean(path)
        return jsonify({'status': 'timeout'})
    except subprocess.CalledProcessError as e:
        clean(path)
        return jsonify({'status': 'error', 'output': e.stdout.decode()})
    
@app.route('/test', methods=['POST'])
def run_command():
    data = request.get_json()
    id = data.get('id')
    test_input = data.get('input', "")

    os.chdir(f'/tmp/{id}')

    try:
        result = subprocess.run(['./main'], input=test_input.encode(), capture_output=True, timeout=5, check=True)
        return jsonify({'status': 'success', 'output': result.stdout.decode()})
    except subprocess.TimeoutExpired:
        return jsonify({'status': 'timeout'})
    except subprocess.CalledProcessError as e:
        return jsonify({'status': 'error', 'output': e.stderr.decode(), 'code': abs(e.returncode)})
    except UnicodeDecodeError:
        return jsonify({'status': 'error', 'output': 'Output encoding error.'})

@app.route('/analyze', methods=['POST'])
def analyze_submission():
    data = request.get_json()
    id = data.get('id')
    params = data.get('params', [])

    os.chdir(f'/tmp/{id}')
    result = run_checks(params)
    print(result)

    return jsonify(result)

def clean(path):
    if os.path.exists(path):
        shutil.rmtree(path)

@app.route('/cleanup', methods=['POST'])
def cleanup():
    data = request.get_json()
    id = data.get('id')
    path = f'/tmp/{id}'
    clean(path)
    return jsonify({'status': 'success'})

if __name__ == '__main__':
    from waitress import serve
    import logging
    logger = logging.getLogger('waitress')
    logger.setLevel(logging.INFO)
    serve(app, host=os.getenv("HOST", '0.0.0.0'), port=int(os.getenv("PORT", '5000')))
