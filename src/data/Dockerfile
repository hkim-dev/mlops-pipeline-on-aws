FROM python:3.12-slim

RUN apt-get update && apt-get install -y gcc

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY preprocess.py .

ENTRYPOINT ["python", "preprocess.py"]