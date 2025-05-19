output "inference_api_url" {
  description = "Public invoke URL for the /predict endpoint"
  value       = "https://${aws_api_gateway_rest_api.inference_api.id}.execute-api.ap-northeast-2.amazonaws.com/prod/predict"
}
