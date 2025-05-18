from datasets import load_dataset
import re
import pandas as pd
import nltk
from nltk.corpus import stopwords
from tqdm import tqdm
import logging
import boto3
from botocore.exceptions import ClientError
import os

# S3 configuration
S3_BUCKET = os.getenv("S3_BUCKET")
S3_KEY = os.getenv("S3_KEY")

nltk.download("stopwords")
stop_words = set(stopwords.words("english"))

def clean_text(text):
    text = text.lower()
    text = re.sub(r'<.*?>', '', text)  # remove HTML tags
    text = re.sub(r'-', ' ', text) # replace hyphens with space to avoid merging compound words
    text = re.sub(r'[^a-z\s]', '', text)  # remove all characters except lowercase letters and whitspace
    text = " ".join([word for word in text.split() if word not in stop_words])
    return text

def preprocess_ag_news():
    dataset = load_dataset("ag_news", split="train[:2000]")
    processed = []

    for item in tqdm(dataset, desc="Preprocessing news articles"):
        text = clean_text(item["text"])
        label = item["label"]  # 0: World, 1: Sports, 2: Business, 3: Sci/Tech
        processed.append({
            "text": text,
            "label": label
        })

    df = pd.DataFrame(processed)

    file_name = "preprocessed_news.csv"
    # save locally
    df.to_csv(file_name, index=False)
    print(f"Saved to {file_name}")

    # upload the CSV to S3
    s3 = boto3.client("s3")
    try:
        s3.upload_file(file_name, S3_BUCKET, S3_KEY)
        print(f"✅ Uploaded {file_name} to s3://{S3_BUCKET}/{S3_KEY}")
    except ClientError as e:
        logging.error("❌ Failed to upload to S3: %s", e)
        raise e

if __name__ == "__main__":
    preprocess_ag_news()
