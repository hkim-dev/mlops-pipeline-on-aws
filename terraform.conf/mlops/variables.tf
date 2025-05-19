variable "ecs_cluster_arn" {
  type        = string
  description = "ECS cluster to run the tasks"
}

variable "ecs_task_execution_role" {
  type        = string
  description = "IAM role used by ECS tasks"
}

variable "log_group_name" {
  type        = string
  description = "CloudWatch log group name for ECS task logs"
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket to store data and models"
}

variable "preprocess_image_url" {
  type        = string
  description = "ECR image URI for preprocess task"
}

variable "train_image_url" {
  type        = string
  description = "ECR image URI for training task"
}

variable "s3_data_key" {
  type        = string
  description = "Key in S3 to save preprocessed CSV"
}

variable "s3_model_key" {
  type        = string
  description = "Key in S3 to upload trained model"
}

variable "s3_vectorizer_key" {
  type        = string
  description = "Key in S3 to upload trained TF-IDF vectorizer"
}

variable "subnet_id" {
  type        = string
  description = "Subnet where ECS task runs"
}

variable "security_group_id" {
  type        = string
  description = "Security group for ECS task networking"
}
