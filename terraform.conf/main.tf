provider "aws" {
  region = "ap-northeast-2"
}

# Core infrastructure: ECS Cluster, IAM roles/policies, CloudWatch log group
module "core" {
  source              = "./core"
  s3_bucket           = var.s3_bucket
}

# MLOps workflow: Preprocessing & training ECS tasks, Step Functions
module "mlops" {
  source = "./mlops"

  ecs_cluster_arn         = module.core.ecs_cluster_arn
  ecs_task_execution_role = module.core.ecs_task_execution_role
  log_group_name          = module.core.log_group_name

  s3_bucket               = var.s3_bucket
  preprocess_image_url    = var.preprocess_image_url
  train_image_url         = var.train_image_url

  s3_data_key             = var.s3_data_key
  s3_model_key            = var.s3_model_key
  s3_vectorizer_key       = var.s3_vectorizer_key

  subnet_id               = var.subnet_id
  security_group_id       = var.security_group_id
}

# API endpoint: Lambda function and REST API for inference
module "api" {
  source = "./api"

  s3_bucket         = var.s3_bucket
  s3_model_key      = var.s3_model_key
  s3_vectorizer_key = var.s3_vectorizer_key
}

output "inference_api_url" {
  value = module.api.inference_api_url
}
