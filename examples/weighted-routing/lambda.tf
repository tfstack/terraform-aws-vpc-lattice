############################################
# Lambda Function
############################################

# Lambda function code (simple HTTP API)
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/external/lambda_function.zip"

  source {
    content  = <<EOF
exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));

    const response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({
            message: "Hello from ${local.base_name_1}-lambda in VPC1!",
            timestamp: new Date().toISOString(),
            event: event
        })
    };

    return response;
};
EOF
    filename = "index.js"
  }
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution" {
  name = "${local.name_1}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.tags_1, {
    Role    = "lambda-execution"
    Service = "lambda-api"
    Purpose = "weighted-routing-backend"
  })
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function
resource "aws_lambda_function" "api_handler" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "${local.name_1}-api"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  environment {
    variables = {
      ENVIRONMENT  = "dev"
      SERVICE_NAME = "lambda-api"
    }
  }

  tags = merge(local.tags_1, {
    Service    = "lambda-api"
    Purpose    = "weighted-routing-backend"
    Deployment = "blue-green-support"
  })
}
