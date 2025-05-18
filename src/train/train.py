import os
import logging
import pandas as pd
import joblib
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score
import boto3
from botocore.exceptions import ClientError

S3_BUCKET = os.getenv("S3_BUCKET")
DATA_KEY = os.getenv("S3_DATA_KEY")
MODEL_KEY = os.getenv("S3_MODEL_KEY")
VECTORIZER_KEY = os.getenv("S3_VECTORIZER_KEY")
LOCAL_DATA = "preprocessed_news.csv"

def download_from_s3():
    s3 = boto3.client("s3")
    try:
        s3.download_file(S3_BUCKET, DATA_KEY, LOCAL_DATA)
        logging.info("✅ Downloaded training data from S3.")
    except ClientError as e:
        logging.error("❌ Failed to download file from S3: %s", e)
        raise

def upload_to_s3(local_file, s3_key):
    s3 = boto3.client("s3")
    try:
        s3.upload_file(local_file, S3_BUCKET, s3_key)
        logging.info("📤 Uploaded %s to s3://%s/%s", local_file, S3_BUCKET, s3_key)
    except ClientError as e:
        logging.error("❌ Failed to upload %s: %s", local_file, e)
        raise

def train():
    # Load data
    download_from_s3()
    df = pd.read_csv(LOCAL_DATA)

    texts = df["text"].fillna("")  # Ensure no NaN
    labels = df["label"]

    # Vectorize text
    vectorizer = TfidfVectorizer(max_features=5000)
    X = vectorizer.fit_transform(texts)

    # Train/test split
    X_train, X_test, y_train, y_test = train_test_split(
        X, labels, test_size=0.2, random_state=42
    )

    # Train model
    model = LogisticRegression(max_iter=1000)
    model.fit(X_train, y_train)

    # Evaluate
    y_pred = model.predict(X_test)
    acc = accuracy_score(y_test, y_pred)
    print(f"✅ Accuracy: {acc:.4f}")
    print(classification_report(y_test, y_pred))

    # Save model & vectorizer
    joblib.dump(model, "news_classifier.pkl")
    joblib.dump(vectorizer, "vectorizer.pkl")
    print("✅ Model and vectorizer saved locally.")

    upload_to_s3("news_classifier.pkl", MODEL_KEY)
    upload_to_s3("vectorizer.pkl", VECTORIZER_KEY)

if __name__ == "__main__":
    train()
