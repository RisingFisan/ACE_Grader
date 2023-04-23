from flask import Flask, request, jsonify
import subprocess
import os
import shutil

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

    output = None

    try:
        result = subprocess.run(['gcc', 'main.c', 'sub.c', '-o', 'main', '-Wall'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=5, check=True)
        return jsonify({'status': 'success', 'output': result.stdout.decode()})
    except subprocess.TimeoutExpired:
        return jsonify({'status': 'timeout'})
    except subprocess.CalledProcessError as e:
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
        return jsonify({'status': 'error', 'error': e.stderr.decode()})

@app.route('/clean', methods=['POST'])
def clean():
    data = request.get_json()
    id = data.get('id')
    path = f'/tmp/{id}'
    if os.path.exists(path):
        shutil.rmtree(path)
    return jsonify({'status': 'success'})

if __name__ == '__main__':
    from waitress import serve
    serve(app, host='0.0.0.0', port=5000)
