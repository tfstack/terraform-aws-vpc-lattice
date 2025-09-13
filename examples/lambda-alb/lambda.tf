############################################
# Lambda Functions
############################################

# Order API Lambda
module "lambda_order_api" {
  source = "tfstack/lambda-versioned/aws"

  function_name = "${local.base_name_2}-order-api"
  handler       = "order-api.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  s3_bucket         = module.s3_bucket.bucket_id
  s3_key            = aws_s3_object.order_api.key
  s3_object_version = aws_s3_object.order_api.version_id

  environment_variables = {
    ENVIRONMENT  = local.tags_2.Environment
    SERVICE_NAME = "order-api"
  }

  vpc_config = {
    vpc_id             = module.vpc_2.vpc_id
    subnet_ids         = module.vpc_2.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = local.tags_2
}

# Lambda Permission for Order API ALB
resource "aws_lambda_permission" "alb_order_api" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_order_api.name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = "arn:aws:elasticloadbalancing:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:targetgroup/${local.name_2}-order-api-${local.suffix}-http/*"
}
