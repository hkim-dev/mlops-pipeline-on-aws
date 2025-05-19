"""
Build commands:

cd api
mkdir -p package
pip install --target ./package -r requirements.txt
cp inference.py package/
cd package
zip -r9 ../lambda.zip .
"""

import json
import boto3
import joblib
import io
import os

CATEGORY_MAP = {
    0: "World",
    1: "Sports",
    2: "Business",
    3: "Sci/Tech"
}

S3_BUCKET = os.environ["S3_BUCKET"]
S3_MODEL_KEY = os.environ["S3_MODEL_KEY"]
S3_VECTORIZER_KEY = os.environ["S3_VECTORIZER_KEY"]

s3 = boto3.client("s3")

def load_pickle_from_s3(key):
    print(f"Downloading s3://{S3_BUCKET}/{key}...")
    response = s3.get_object(Bucket=S3_BUCKET, Key=key)
    body = response["Body"].read()
    return joblib.load(io.BytesIO(body)) # make file stream "seekable"

model = load_pickle_from_s3(S3_MODEL_KEY)
vectorizer = load_pickle_from_s3(S3_VECTORIZER_KEY)

def lambda_handler(event, context):
    try:
        body = json.loads(event["body"])
        text = body["text"]
        X = vectorizer.transform([text])
        prediction = model.predict(X)[0]
        return {
            "statusCode": 200,
            "body": json.dumps({
                "prediction": int(prediction),
                "label": CATEGORY_MAP[int(prediction)],
            })
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({ "error": str(e) })
        }

if __name__ == "__main__":
    sample_event = {
        "body": json.dumps({
            "text": "Apple reports record profits for Q1 as iPhone sales surge"
        })
    }

    result = lambda_handler(sample_event, None)
    print("🔮 Lambda output:")
    print(json.dumps(json.loads(result["body"]), indent=2))