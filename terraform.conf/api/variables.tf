variable "s3_bucket" {
  type        = string
  description = "S3 bucket where the model and vectorizer are stored"
}

variable "s3_model_key" {
  type        = string
  description = "Key for the trained model in S3"
}

variable "s3_vectorizer_key" {
  type        = string
  description = "Key for the TF-IDF vectorizer in S3"
}
