from datasets import load_dataset
import re
import pandas as pd
import nltk
from nltk.corpus import stopwords
from tqdm import tqdm

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
    df.to_csv("preprocessed_news.csv", index=False)
    print("Saved to preprocessed_news.csv")

if __name__ == "__main__":
    preprocess_ag_news()
