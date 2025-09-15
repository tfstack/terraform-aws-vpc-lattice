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
                module.vpc_2.vpc_id,
                module.vpc_3.vpc_id
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
      security_group_ids = [
        aws_security_group.vpc_lattice_2_sg.id
      ]
      tags = local.tags_2
    },
    {
      vpc_id = module.vpc_3.vpc_id
      security_group_ids = [
        aws_security_group.vpc_lattice_3_sg.id
      ]
      tags = local.tags_3
    }
  ]

  # Enable automatic Route 53 zone creation for custom domains
  create_route53_zone = true
  route53_zone_name   = "example.local"
  route53_vpc_ids = [
    module.vpc_1.vpc_id,
    module.vpc_2.vpc_id,
    module.vpc_3.vpc_id
  ]
  route53_zone_tags = {
    DNSZone = "custom-domain"
    Purpose = "service-discovery"
  }

  services = [
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
          name                           = "orders-service"
          type                           = "LAMBDA"
          protocol                       = "HTTP"
          port                           = 80
          vpc_id                         = module.vpc_2.vpc_id
          lambda_event_structure_version = "V1"
          targets = [
            {
              target_id = module.lambda_orders_service.arn
            }
          ]
          tags = {
            Service = "orders"
            Domain  = "business"
          }
        },
        {
          name                           = "payments-service"
          type                           = "LAMBDA"
          protocol                       = "HTTP"
          port                           = 80
          vpc_id                         = module.vpc_2.vpc_id
          lambda_event_structure_version = "V1"
          targets = [
            {
              target_id = module.lambda_payments_service.arn
            }
          ]
          tags = {
            Service = "payments"
            Domain  = "financial"
          }
        },
        {
          name                           = "inventory-service"
          type                           = "LAMBDA"
          protocol                       = "HTTP"
          port                           = 80
          vpc_id                         = module.vpc_2.vpc_id
          lambda_event_structure_version = "V1"
          targets = [
            {
              target_id = module.lambda_inventory_service.arn
            }
          ]
          tags = {
            Service = "inventory"
            Domain  = "business"
          }
        },
        {
          name     = "analytics-service"
          type     = "ALB"
          protocol = "HTTP"
          port     = 80
          vpc_id   = module.vpc_3.vpc_id
          targets = [
            {
              target_id = module.ecs_cluster_fargate.alb_arns["analytics-service"]
              port      = 8000
            }
          ]
          health_check = {
            path                = "/health"
            interval            = 10
            timeout             = 5
            healthy_threshold   = 1
            unhealthy_threshold = 2
          }
          tags = {
            Service    = "analytics"
            Domain     = "reporting"
            TargetType = "ECS_FARGATE"
            Version    = "1.0"
          }
        },
        {
          name     = "notifications-service"
          type     = "INSTANCE"
          protocol = "HTTP"
          port     = 80
          vpc_id   = module.vpc_3.vpc_id
          targets = [
            {
              target_id = module.ec2_notifications_service.instance_id
              port      = 80
            }
          ]
          health_check = {
            path                = "/health"
            interval            = 10
            timeout             = 5
            healthy_threshold   = 1
            unhealthy_threshold = 2
          }
          tags = {
            Service    = "notifications"
            Domain     = "communication"
            TargetType = "EC2"
            Version    = "1.0"
          }
        },
        {
          name     = "health-service"
          type     = "IP"
          protocol = "HTTP"
          port     = 80
          vpc_id   = module.vpc_3.vpc_id
          targets = [
            {
              target_id = module.ec2_health_service.private_ip
              port      = 80
            }
          ]
          health_check = {
            path                = "/health"
            interval            = 10
            timeout             = 5
            healthy_threshold   = 1
            unhealthy_threshold = 2
          }
          tags = {
            Service    = "health"
            Domain     = "health"
            TargetType = "IP"
            Version    = "1.0"
          }
        },
        {
          name                           = "notfound-service"
          type                           = "LAMBDA"
          protocol                       = "HTTP"
          port                           = 80
          vpc_id                         = module.vpc_2.vpc_id
          weight                         = 1
          lambda_event_structure_version = "V1"
          targets = [
            {
              target_id = module.lambda_notfound_service.arn
            }
          ]
          tags = {
            Service = "notfound"
            Domain  = "error"
          }
        }
      ]

      default_action = {
        target_group_name = "notfound-service"
        weight            = 1
      }

      listener_rules = [
        {
          priority          = 20
          target_group_name = "orders-service"
          match = {
            http_match = {
              path = "/orders"
            }
          }
          action = {
            weight = 1
          }
          tags = {
            RuleType = "orders-route"
            Priority = "20"
            Domain   = "business"
          }
        },
        {
          priority          = 30
          target_group_name = "payments-service"
          match = {
            http_match = {
              path = "/payments"
            }
          }
          action = {
            weight = 1
          }
          tags = {
            RuleType = "payments-route"
            Priority = "30"
            Domain   = "financial"
          }
        },
        {
          priority          = 40
          target_group_name = "inventory-service"
          match = {
            http_match = {
              path = "/inventory"
            }
          }
          action = {
            weight = 1
          }
          tags = {
            RuleType = "inventory-route"
            Priority = "40"
            Domain   = "business"
          }
        },
        {
          priority          = 50
          target_group_name = "analytics-service"
          match = {
            http_match = {
              path = "/analytics"
            }
          }
          action = {
            weight = 1
          }
          tags = {
            RuleType = "analytics-route"
            Priority = "50"
            Domain   = "reporting"
          }
        },
        {
          priority          = 60
          target_group_name = "notifications-service"
          match = {
            http_match = {
              path = "/notifications"
            }
          }
          action = {
            weight = 1
          }
          tags = {
            RuleType = "notifications-route"
            Priority = "60"
            Domain   = "communication"
          }
        },
        {
          priority          = 70
          target_group_name = "health-service"
          match = {
            http_match = {
              path = "/health"
            }
          }
          action = {
            weight = 1
          }
          tags = {
            RuleType = "health-route"
            Priority = "70"
            Domain   = "health"
          }
        }
      ]
      tags = {
        Service      = "api"
        RoutingType  = "domain-based"
        Architecture = "microservices"
      }
    },
    {
      name      = "products"
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

      custom_name = "products"

      target_groups = [
        {
          name                           = "products-service-v1"
          type                           = "LAMBDA"
          protocol                       = "HTTP"
          port                           = 80
          vpc_id                         = module.vpc_2.vpc_id
          weight                         = 50
          lambda_event_structure_version = "V1"
          targets = [
            {
              target_id = module.lambda_products_service.arn
            }
          ]
          tags = {
            Service = "products-v1"
            Domain  = "catalog"
            Version = "v1"
          }
        },
        {
          name                           = "products-service-v2"
          type                           = "LAMBDA"
          protocol                       = "HTTP"
          port                           = 80
          vpc_id                         = module.vpc_2.vpc_id
          weight                         = 50
          lambda_event_structure_version = "V1"
          targets = [
            {
              target_id = module.lambda_products_service_v2.arn
            }
          ]
          tags = {
            Service = "products-v2"
            Domain  = "catalog"
            Version = "v2"
          }
        }
      ]

      tags = {
        Service     = "products"
        RoutingType = "weighted"
        Version     = "v1-v2-split"
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
