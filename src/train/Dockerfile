FROM python:3.12-slim

RUN apt-get update && apt-get install -y gcc && apt-get clean

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY train.py .

ENTRYPOINT ["python", "train.py"]