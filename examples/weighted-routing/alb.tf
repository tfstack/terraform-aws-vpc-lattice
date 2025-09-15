module "alb" {
  source = "tfstack/alb/aws"

  name               = "cltest3"
  suffix             = local.suffix
  vpc_id             = module.vpc_3.vpc_id
  private_subnet_ids = module.vpc_3.private_subnet_ids

  # Internal ALB Configuration
  internal = true

  # Enhanced Health Check Configuration
  health_check_enabled             = true
  health_check_path                = "/health"
  health_check_interval            = 30
  health_check_timeout             = 5
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 2
  health_check_matcher             = "200,302"
  health_check_port                = "traffic-port"
  health_check_protocol            = "HTTP"

  # Security Group Configuration
  use_existing_security_group = false
  existing_security_group_id  = ""

  # Listener Configuration
  enable_https     = false
  http_port        = 80
  target_http_port = 80
  targets          = aws_instance.ec2_web_server_5[*].id
  target_type      = "instance"

  # Security - Restrict access to VPC only
  allowed_http_cidrs   = concat(module.vpc_3.private_subnet_cidrs, [local.vpc_lattice_cidr])
  allowed_https_cidrs  = concat(module.vpc_3.private_subnet_cidrs, [local.vpc_lattice_cidr])
  allowed_egress_cidrs = ["0.0.0.0/0"]

  tags = local.tags_3
}
