resource "aws_iam_role" "lambda_role" {
  name = "lambda-inference-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-s3-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetObject"],
        Resource = "arn:aws:s3:::${var.s3_bucket}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "inference" {
  function_name = "news-inference"
  filename      = "${path.module}/../src/api/lambda.zip"
  handler       = "inference.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 15

  source_code_hash = filebase64sha256("${path.module}/../../src/api/lambda.zip")

  environment {
    variables = {
      S3_BUCKET         = var.s3_bucket
      S3_MODEL_KEY      = var.s3_model_key
      S3_VECTORIZER_KEY = var.s3_vectorizer_key
    }
  }
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "inference_api" {
  name        = "news-inference-api"
  description = "API for news category prediction"
}

resource "aws_api_gateway_resource" "predict" {
  rest_api_id = aws_api_gateway_rest_api.inference_api.id
  parent_id   = aws_api_gateway_rest_api.inference_api.root_resource_id
  path_part   = "predict"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.inference_api.id
  resource_id   = aws_api_gateway_resource.predict.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.inference_api.id
  resource_id             = aws_api_gateway_resource.predict.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.inference.invoke_arn
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.inference.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.inference_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "inference_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.inference_api.id
}