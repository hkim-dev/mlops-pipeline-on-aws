resource "aws_ecs_task_definition" "mlops_train_task" {
  family                   = "mlops-train"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "mlops-train",
      image     = var.train_image_url,
      essential = true,
      environment = [
        {
          name  = "S3_BUCKET",
          value = var.s3_bucket
        },
        {
          name  = "S3_DATA_KEY",
          value = var.s3_data_key
        },
        {
          name  = "S3_MODEL_KEY",
          value = var.s3_model_key
        },
        {
          name  = "S3_VECTORIZER_KEY",
          value = var.s3_vectorizer_key
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/mlops",
          awslogs-region        = "ap-northeast-2",
          awslogs-stream-prefix = "train"
        }
      }
    }
  ])
}
