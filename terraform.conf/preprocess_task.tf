resource "aws_ecs_task_definition" "mlops_preprocess_task" {
  family                   = "mlops-preprocess"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "mlops-preprocess"
      image     = var.preprocess_image_url
      essential = true
      environment = [
        {
          name  = "S3_BUCKET"
          value = var.s3_bucket
        },
        {
          name  = "S3_KEY"
          value = var.s3_data_key
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/mlops",
          awslogs-region        = "ap-northeast-2",
          awslogs-stream-prefix = "preprocess"
        }
      }
    }
  ])
}
