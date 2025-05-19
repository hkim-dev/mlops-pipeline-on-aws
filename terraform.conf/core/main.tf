# terraform script that defines shared infrastructure

resource "aws_ecs_cluster" "mlops_cluster" {
  name = "mlops-cluster"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "custom_s3_policy" {
  name = "ecs-access-s3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject"],
        Resource = "arn:aws:s3:::${var.s3_bucket}/*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_s3_attach" {
  name       = "ecs-s3-policy-attachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = aws_iam_policy.custom_s3_policy.arn
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/mlops"
  retention_in_days = 7
}
