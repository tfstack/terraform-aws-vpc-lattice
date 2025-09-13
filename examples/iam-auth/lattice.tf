
############################################
# VPC Lattice Configuration
############################################

module "vpc_lattice" {
  source = "../../"

  create_service_network = true
  service_network = {
    name      = "${local.name_1}-network"
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
      name      = "web"
      protocol  = "HTTP"
      port      = 80
      auth_type = "NONE"

      custom_name = "web"

      target_groups = [
        {
          name     = "alb-web-server-1"
          type     = "ALB"
          protocol = "HTTP"
          port     = 8000
          vpc_id   = module.vpc_2.vpc_id
          targets = [
            {
              target_id = module.ecs_cluster_fargate.alb_arns["hello-webapp"]
              port      = 8000
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
            TargetGroup = "alb-web-server-1"
          }
        }
      ]

      default_action = {
        target_group_name = "alb-web-server-1"
        weight            = 1
      }

      tags = {
        Service     = "web"
        RoutingType = "iam-auth"
      }
    },
    {
      name      = "api"
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
        RoutingType = "iam-auth"
      }
    }
  ]

  create_log_group          = true
  log_group_name            = "/aws/vpclattice/${local.name_1}"
  log_retention_days        = 1
  log_group_prevent_destroy = false

  tags = {
    Module  = "vpc-lattice"
    Example = "iam-auth"
  }
}
