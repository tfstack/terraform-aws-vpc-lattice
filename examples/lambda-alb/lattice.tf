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
    tags = local.tags_1
  }

  vpc_associations = [
    {
      vpc_id = module.vpc_1.vpc_id
      # security_group_ids = [
      #   aws_security_group.vpc_lattice_1_sg.id
      # ]
      tags = local.tags_1
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
  route53_zone_tags = {
    DNSZone = "custom-domain"
    Purpose = "service-discovery"
  }

  services = [
    {
      name      = "order-api"
      protocol  = "HTTP"
      port      = 80
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

      custom_name = "order-api"

      target_groups = [
        {
          name     = "lambda-order-api-tg"
          type     = "ALB"
          protocol = "HTTP"
          port     = 80
          vpc_id   = module.vpc_2.vpc_id
          targets = [
            {
              target_id = module.alb_order_api.alb_arn
              port      = 80
            }
          ]
          health_check = {
            path                = "/"
            interval            = 10
            timeout             = 5
            healthy_threshold   = 1
            unhealthy_threshold = 2
          }
          tags = {
            Service = "lambda-order-api"
            Domain  = "lambda"
          }
        }
      ]
      default_action = {
        target_group_name = "lambda-order-api-tg"
        weight            = 1
      }

      tags = {
        Service     = "lambda-order-api"
        RoutingType = "iam-auth"
      }
    }
  ]

  create_log_group          = true
  log_group_name            = "/aws/vpclattice/cltest"
  log_retention_days        = 1
  log_group_prevent_destroy = false

  tags = {
    Module  = "vpc-lattice"
    Example = "iam-auth"
  }
}
