FROM python:3.11-slim-buster

WORKDIR /python-grader

RUN apt-get update && \
    apt-get -y install gcc && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD [ "python", "./grader.py"]