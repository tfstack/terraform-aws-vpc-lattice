############################################
# Lambda Functions
############################################

module "lambda_products_service" {
  source = "tfstack/lambda-versioned/aws"

  function_name = "${local.base_name_2}-products-service"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  s3_bucket         = module.s3_bucket_1.bucket_id
  s3_key            = aws_s3_object.products_service.key
  s3_object_version = aws_s3_object.products_service.version_id

  environment_variables = {
    ENVIRONMENT  = local.tags_2.Environment
    SERVICE_NAME = "products-service"
  }

  vpc_config = {
    vpc_id             = module.vpc_2.vpc_id
    subnet_ids         = module.vpc_2.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = local.tags_2
}

module "lambda_orders_service" {
  source = "tfstack/lambda-versioned/aws"

  function_name = "${local.base_name_2}-orders-service"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  s3_bucket         = module.s3_bucket_1.bucket_id
  s3_key            = aws_s3_object.orders_service.key
  s3_object_version = aws_s3_object.orders_service.version_id

  environment_variables = {
    ENVIRONMENT  = local.tags_2.Environment
    SERVICE_NAME = "orders-service"
  }

  vpc_config = {
    vpc_id             = module.vpc_2.vpc_id
    subnet_ids         = module.vpc_2.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = local.tags_2
}

module "lambda_payments_service" {
  source = "tfstack/lambda-versioned/aws"

  function_name = "${local.base_name_2}-payments-service"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  s3_bucket         = module.s3_bucket_1.bucket_id
  s3_key            = aws_s3_object.payments_service.key
  s3_object_version = aws_s3_object.payments_service.version_id

  environment_variables = {
    ENVIRONMENT  = local.tags_2.Environment
    SERVICE_NAME = "payments-service"
  }

  vpc_config = {
    vpc_id             = module.vpc_2.vpc_id
    subnet_ids         = module.vpc_2.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = local.tags_2
}

module "lambda_inventory_service" {
  source = "tfstack/lambda-versioned/aws"

  function_name = "${local.base_name_2}-inventory-service"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  s3_bucket         = module.s3_bucket_1.bucket_id
  s3_key            = aws_s3_object.inventory_service.key
  s3_object_version = aws_s3_object.inventory_service.version_id

  environment_variables = {
    ENVIRONMENT  = local.tags_2.Environment
    SERVICE_NAME = "inventory-service"
  }

  vpc_config = {
    vpc_id             = module.vpc_2.vpc_id
    subnet_ids         = module.vpc_2.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = local.tags_2
}

module "lambda_analytics_service" {
  source = "tfstack/lambda-versioned/aws"

  function_name = "${local.base_name_2}-analytics-service"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  s3_bucket         = module.s3_bucket_1.bucket_id
  s3_key            = aws_s3_object.analytics_service.key
  s3_object_version = aws_s3_object.analytics_service.version_id

  environment_variables = {
    ENVIRONMENT  = local.tags_2.Environment
    SERVICE_NAME = "analytics-service"
  }

  vpc_config = {
    vpc_id             = module.vpc_2.vpc_id
    subnet_ids         = module.vpc_2.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = local.tags_2
}

module "lambda_notfound_service" {
  source = "tfstack/lambda-versioned/aws"

  function_name = "${local.base_name_2}-notfound-service"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  s3_bucket         = module.s3_bucket_1.bucket_id
  s3_key            = aws_s3_object.notfound_service.key
  s3_object_version = aws_s3_object.notfound_service.version_id

  environment_variables = {
    ENVIRONMENT  = local.tags_2.Environment
    SERVICE_NAME = "notfound-service"
  }

  vpc_config = {
    vpc_id             = module.vpc_2.vpc_id
    subnet_ids         = module.vpc_2.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = local.tags_2
}

module "lambda_products_service_v2" {
  source = "tfstack/lambda-versioned/aws"

  function_name = "${local.base_name_2}-products-service-v2"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  s3_bucket         = module.s3_bucket_1.bucket_id
  s3_key            = aws_s3_object.productsv2_service.key
  s3_object_version = aws_s3_object.productsv2_service.version_id

  environment_variables = {
    ENVIRONMENT  = local.tags_2.Environment
    SERVICE_NAME = "products-service-v2"
  }

  vpc_config = {
    vpc_id             = module.vpc_2.vpc_id
    subnet_ids         = module.vpc_2.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = local.tags_2
}
