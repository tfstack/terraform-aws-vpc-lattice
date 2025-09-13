# ############################################
# # Lambda Function
# ############################################

module "lambda_api" {
  source = "tfstack/lambda-versioned/aws"

  function_name = "${local.base_name_2}-api"
  handler       = "index.handler"
  runtime       = "python3.13"
  timeout       = 30

  s3_bucket         = module.s3_bucket.bucket_id
  s3_key            = aws_s3_object.api.key
  s3_object_version = aws_s3_object.api.version_id

  environment_variables = {
    ENVIRONMENT  = local.tags_1.Environment
    SERVICE_NAME = "api"
  }

  vpc_config = {
    vpc_id             = module.vpc_2.vpc_id
    subnet_ids         = module.vpc_2.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = local.tags_2
}
