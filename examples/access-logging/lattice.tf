
############################################
# VPC Lattice Configuration
############################################

module "vpc_lattice" {
  source = "../../"

  create_service_network = true
  service_network = {
    name      = "cltest-network"
    auth_type = "AWS_IAM"
    auth_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = "*"
          Action    = ["vpc-lattice-svcs:Invoke"]
          Resource  = "*"
          Condition = {
            StringEquals = {
              "vpc-lattice-svcs:SourceVpc" = [
                module.vpc_1.vpc_id,
                module.vpc_2.vpc_id
              ]
            }
          }
        }
      ]
    })
    # Configure access logging - module will create log group automatically
    log_config = {}

    tags = local.tags_1
  }

  vpc_associations = [
    {
      vpc_id = module.vpc_1.vpc_id
      tags   = local.tags_1
    },
    {
      vpc_id = module.vpc_2.vpc_id
      security_group_ids = [
        aws_security_group.vpc_lattice_2_sg.id
      ]
      tags = local.tags_2
    }
  ]

  # Enable automatic Route 53 zone creation for custom domains
  create_route53_zone = true
  route53_zone_name   = "example.local"
  route53_vpc_ids = [
    module.vpc_1.vpc_id,
    module.vpc_2.vpc_id
  ]
  route53_zone_tags = local.tags_2

  services = [
    {
      name      = "api"
      protocol  = "HTTP"
      port      = 80
      auth_type = "NONE"

      custom_name = "api"

      # Service-level access logging - module will create log group automatically
      log_config = {}

      target_groups = [
        {
          name                           = "lambda-tg"
          type                           = "LAMBDA"
          protocol                       = "HTTP"
          port                           = 80
          vpc_id                         = module.vpc_2.vpc_id
          lambda_event_structure_version = "V1"
          targets = [
            {
              target_id = module.lambda_api.arn
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
        RoutingType = "access-logging"
      }
    }
  ]

  # Basic CloudWatch log group for module logs
  create_log_group          = true
  log_group_name            = "/aws/vpclattice/${local.base_name_2}"
  log_retention_days        = 7
  log_group_prevent_destroy = false

  # Enable per-service log groups
  create_per_service_log_groups = true

  # Enable resource access logs (API calls, management operations)
  # Note: Disabled because we have service access logs (log_config) on API service
  # enable_resource_access_logs = true

  tags = {
    Module  = "vpc-lattice"
    Example = "access-logging"
  }
}
