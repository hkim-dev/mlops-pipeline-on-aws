variable "s3_bucket" {
  description = "S3 bucket used to store data and models"
  type        = string
}

variable "preprocess_image_url" {
  description = "ECR image URL for preprocess task"
  type        = string
}

variable "s3_data_key" {
  description = "S3 object key to save the preprocessed CSV"
  type        = string
}

variable "train_image_url" {
  description = "ECR image URL for training task"
  type        = string
}

variable "s3_model_key" {
  description = "S3 object key to upload the trained model"
  type        = string
}

variable "s3_vectorizer_key" {
  description = "S3 object key to upload the trained TF-IDF vectorizer"
  type        = string
}

variable "subnet_id" {}
variable "security_group_id" {}
