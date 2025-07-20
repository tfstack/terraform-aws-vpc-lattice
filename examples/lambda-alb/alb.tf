############################################
# AWS ALB Module (Internal)
############################################

module "alb_order_api" {
  source = "tfstack/alb/aws"

  name               = "${local.name_2}-order-api"
  suffix             = local.suffix
  vpc_id             = module.vpc_2.vpc_id
  private_subnet_ids = module.vpc_2.private_subnet_ids

  # Internal ALB Configuration
  internal = true

  # Security Group Configuration
  use_existing_security_group = false
  existing_security_group_id  = ""

  # Listener Configuration
  enable_https     = false
  http_port        = 80
  target_http_port = 80
  targets          = [module.lambda_order_api.arn]
  target_type      = "lambda"

  # Health check configuration for Lambda (disabled)
  health_check_enabled = false

  # Security - Restrict access to VPC and VPC Lattice
  allowed_http_cidrs   = concat(module.vpc_2.private_subnet_cidrs, [local.vpc_lattice_cidr])
  allowed_https_cidrs  = concat(module.vpc_2.private_subnet_cidrs, [local.vpc_lattice_cidr])
  allowed_egress_cidrs = ["0.0.0.0/0"]

  tags = local.tags_2

  depends_on = [
    aws_lambda_permission.alb_order_api
  ]
}
