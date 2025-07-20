############################################
# VPC Lattice Configuration
############################################

module "vpc_lattice" {
  source = "../../"

  create_service_network = true
  service_network = {
    name      = "ecommerce-network"
    auth_type = "NONE"
    tags = {
      Name        = "ecommerce-network"
      NetworkType = "service-network"
      Environment = "dev"
    }
  }

  vpc_associations = [
    {
      vpc_id = module.vpc_1.vpc_id
      security_group_ids = [
        aws_security_group.vpc_lattice_1_sg.id
      ]
      tags = {
        VPCType = "client"
      }
    },
    {
      vpc_id = module.vpc_2.vpc_id
      security_group_ids = [
        aws_security_group.vpc_lattice_2_sg.id
      ]
      tags = {
        VPCType = "lambda-api"
      }
    }
  ]

  # Enable automatic Route 53 zone creation for custom domains
  create_route53_zone = true
  route53_zone_name   = "ecommerce.local"
  route53_vpc_ids = [
    module.vpc_1.vpc_id,
    module.vpc_2.vpc_id
  ]
  route53_zone_tags = {
    DNSZone     = "ecommerce-domain"
    Purpose     = "service-discovery"
    Environment = "dev"
  }

  services = [
    {
      name      = "api"
      protocol  = "HTTP"
      port      = 80
      auth_type = "NONE"

      custom_name = "api"

      target_groups = [
        {
          name                           = "products-service"
          type                           = "LAMBDA"
          protocol                       = "HTTP"
          port                           = 80
          vpc_id                         = module.vpc_2.vpc_id
          lambda_event_structure_version = "V1"
          targets = [
            {
              target_id = aws_lambda_function.products_handler.arn
            }
          ]
          tags = {
            Service = "products"
            Domain  = "catalog"
          }
        },
        {
          name                           = "orders-service"
          type                           = "LAMBDA"
          protocol                       = "HTTP"
          port                           = 80
          vpc_id                         = module.vpc_2.vpc_id
          lambda_event_structure_version = "V1"
          targets = [
            {
              target_id = aws_lambda_function.orders_handler.arn
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
              target_id = aws_lambda_function.payments_handler.arn
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
              target_id = aws_lambda_function.inventory_handler.arn
            }
          ]
          tags = {
            Service = "inventory"
            Domain  = "business"
          }
        },
        {
          name                           = "analytics-service"
          type                           = "LAMBDA"
          protocol                       = "HTTP"
          port                           = 80
          vpc_id                         = module.vpc_2.vpc_id
          lambda_event_structure_version = "V1"
          targets = [
            {
              target_id = aws_lambda_function.analytics_handler.arn
            }
          ]
          tags = {
            Service = "analytics"
            Domain  = "reporting"
          }
        },
        {
          name                           = "notfound-service"
          type                           = "LAMBDA"
          protocol                       = "HTTP"
          port                           = 80
          vpc_id                         = module.vpc_2.vpc_id
          lambda_event_structure_version = "V1"
          targets = [
            {
              target_id = aws_lambda_function.notfound_handler.arn
            }
          ]
          tags = {
            Service = "notfound"
            Domain  = "error"
          }
        }
      ]

      # Default action for unmatched requests - route to notfound service
      default_action = {
        target_group_name = "notfound-service"
        weight            = 1
      }

      # Listener rules for content-based routing based on business domains
      listener_rules = [
        {
          priority          = 10
          target_group_name = "products-service"
          match = {
            http_match = {
              path = "/products"
            }
          }
          action = {
            weight = 1
          }
          tags = {
            RuleType = "products-route"
            Priority = "10"
            Domain   = "catalog"
          }
        },
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
        }
      ]

      tags = {
        Service      = "api"
        RoutingType  = "domain-based"
        Architecture = "microservices"
      }
    }
  ]

  create_log_group          = true
  log_group_name            = "/aws/vpclattice/ecommerce-network"
  log_retention_days        = 7
  log_group_prevent_destroy = false

  tags = {
    Module       = "vpc-lattice"
    Example      = "ecommerce-microservices"
    Environment  = "dev"
    Architecture = "microservices"
  }
}
