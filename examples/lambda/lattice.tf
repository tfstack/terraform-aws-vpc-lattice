
############################################
# VPC Lattice Configuration
############################################

module "vpc_lattice" {
  source = "../../"

  create_service_network = true
  service_network = {
    name      = "${local.name_1}-network"
    auth_type = "NONE"

    tags = local.tags_1
  }

  vpc_associations = [
    {
      vpc_id = module.vpc_1.vpc_id
      tags   = local.tags_1
    },
    {
      vpc_id = module.vpc_2.vpc_id
      tags   = local.tags_2
    }
  ]

  # Enable automatic Route 53 zone creation for custom domains
  create_route53_zone = true
  route53_zone_name   = "example.local"
  route53_vpc_ids = [
    module.vpc_1.vpc_id,
    module.vpc_2.vpc_id
  ]
  route53_zone_tags = local.tags_1

  services = [
    {
      name      = "api"
      protocol  = "HTTP"
      port      = 80
      auth_type = "NONE"

      custom_name = "api"

      target_groups = [
        {
          name                           = "lambda-tg"
          type                           = "LAMBDA"
          protocol                       = "HTTP"
          port                           = 80
          vpc_id                         = module.vpc_1.vpc_id
          lambda_event_structure_version = "V1"
          targets = [
            {
              target_id = aws_lambda_function.api_handler.arn
            }
          ]
          tags = {
            Service = "lambda-api"
            Domain  = "lambda"
          }
        }
      ]

      default_action = {
        target_group_name = "lambda-tg"
        weight            = 1
      }

      tags = {
        Service     = "lambda-api"
        RoutingType = "none"
      }
    }
  ]

  create_log_group          = true
  log_group_name            = "/aws/vpclattice/${local.name_1}"
  log_retention_days        = 1
  log_group_prevent_destroy = false

  tags = {
    Module  = "vpc-lattice"
    Example = "lambda"
  }
}
