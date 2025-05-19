resource "aws_ecs_task_definition" "mlops_preprocess_task" {
  family                   = "mlops-preprocess"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_task_execution_role
  task_role_arn            = var.ecs_task_execution_role

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

resource "aws_ecs_task_definition" "mlops_train_task" {
  family                   = "mlops-train"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_task_execution_role
  task_role_arn            = var.ecs_task_execution_role

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


resource "aws_sfn_state_machine" "mlops_pipeline" {
  name     = "mlops-pipeline"
  role_arn = aws_iam_role.step_function_execution_role.arn

  definition = jsonencode({
    Comment = "News MLOps Step Function",
    StartAt = "PreprocessTask",
    States = {
      PreprocessTask = {
        Type = "Task",
        Resource = "arn:aws:states:::ecs:runTask.sync",
        Parameters = {
          LaunchType = "FARGATE",
          Cluster    = var.ecs_cluster_arn,
          TaskDefinition = aws_ecs_task_definition.mlops_preprocess_task.arn,
          NetworkConfiguration = {
            AwsvpcConfiguration = {
              Subnets         = [var.subnet_id],
              SecurityGroups  = [var.security_group_id],
              AssignPublicIp  = "ENABLED"
            }
          },
          Overrides = {
            ContainerOverrides = [
              {
                Name = "mlops-preprocess",
                Environment = [
                  { Name = "S3_BUCKET", Value = var.s3_bucket },
                  { Name = "S3_KEY", Value = var.s3_data_key }
                ]
              }
            ]
          }
        },
        Next = "TrainTask"
      },
      TrainTask = {
        Type = "Task",
        Resource = "arn:aws:states:::ecs:runTask.sync",
        Parameters = {
          LaunchType = "FARGATE",
          Cluster    = var.ecs_cluster_arn,
          TaskDefinition = aws_ecs_task_definition.mlops_train_task.arn,
          NetworkConfiguration = {
            AwsvpcConfiguration = {
              Subnets         = [var.subnet_id],
              SecurityGroups  = [var.security_group_id],
              AssignPublicIp  = "ENABLED"
            }
          },
          Overrides = {
            ContainerOverrides = [
              {
                Name = "mlops-train",
                Environment = [
                  { Name = "S3_BUCKET", Value = var.s3_bucket },
                  { Name = "S3_DATA_KEY", Value = var.s3_data_key },
                  { Name = "S3_MODEL_KEY", Value = var.s3_model_key },
                  { Name = "S3_VECTORIZER_KEY", Value = var.s3_vectorizer_key }
                ]
              }
            ]
          }
        },
        End = true
      }
    }
  })
}

resource "aws_iam_role" "step_function_execution_role" {
  name = "stepFunctionExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "states.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "step_function_inline_policy" {
  name = "stepFunctionInlinePolicy"
  role = aws_iam_role.step_function_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:RunTask",
          "ecs:DescribeTasks",
          "ecs:DescribeTaskDefinition",
          "iam:PassRole"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "events:PutTargets",
          "events:PutRule",
          "events:DescribeRule"
        ],
        Resource = "*"
      }
    ]
  })
}
