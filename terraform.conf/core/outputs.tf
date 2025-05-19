output "ecs_cluster_arn" {
  value = aws_ecs_cluster.mlops_cluster.arn
}

output "ecs_task_execution_role" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.ecs_log_group.name
}