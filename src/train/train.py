import pandas as pd
import joblib
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score
import os

DATA_PATH = "../data/preprocessed_news.csv"
MODEL_DIR = "../models"
os.makedirs(MODEL_DIR, exist_ok=True)

def train():
    # Load data
    df = pd.read_csv(DATA_PATH)
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
    print(f"Accuracy: {acc:.4f}")
    print(classification_report(y_test, y_pred))

    # Save model & vectorizer
    joblib.dump(model, os.path.join(MODEL_DIR, "news_classifier.pkl"))
    joblib.dump(vectorizer, os.path.join(MODEL_DIR, "vectorizer.pkl"))
    print("Model and vectorizer saved.")

if __name__ == "__main__":
    train()
