output "preprocess_task_arn" {
  value = aws_ecs_task_definition.mlops_preprocess_task.arn
}

output "train_task_arn" {
  value = aws_ecs_task_definition.mlops_train_task.arn
}
