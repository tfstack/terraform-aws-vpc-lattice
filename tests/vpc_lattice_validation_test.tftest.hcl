run "validation_tests" {
  command = plan

  variables {
    service_network = {
      name      = "validation-test-network"
      auth_type = "AWS_IAM"
    }
    vpc_associations = [
      {
        vpc_id = "vpc-test-id"
      }
    ]
    services = [
      {
        name      = "validation-service"
        protocol  = "HTTP"
        port      = 80
        auth_type = "AWS_IAM"
        target_groups = [
          {
            name     = "validation-tg"
            type     = "ALB"
            port     = 80
            protocol = "HTTP"
            vpc_id   = "vpc-test-id"
            targets = [
              {
                target_id = "arn:aws:elasticloadbalancing:ap-southeast-2:123456789012:loadbalancer/app/validation-alb/1234567890123456"
                port      = 80
              }
            ]
            health_check = {
              path     = "/health"
              interval = 30
              timeout  = 5
            }
          }
        ]
        default_action = {
          target_group_name = "validation-tg"
          weight            = 1
        }
        listener_rules = [
          {
            priority          = 10
            target_group_name = "validation-tg"
            match = {
              http_match = {
                header_name  = "X-Service"
                header_value = "validation"
                path         = "/api/*"
              }
            }
            action = {
              weight = 1
            }
          }
        ]
      }
    ]
    create_log_group   = true
    log_group_name     = "/aws/vpclattice/validation"
    log_retention_days = 7
  }

  # Test service network validation
  assert {
    condition     = can(var.service_network.name)
    error_message = "Service network name should be valid"
  }

  assert {
    condition     = can(var.service_network.auth_type)
    error_message = "Service network auth type should be valid"
  }

  # Test service validation
  assert {
    condition     = length(var.services) > 0
    error_message = "Services should not be empty"
  }

  assert {
    condition     = can(var.services[0].name)
    error_message = "Service name should be valid"
  }

  assert {
    condition     = can(var.services[0].protocol)
    error_message = "Service protocol should be valid"
  }

  assert {
    condition     = can(var.services[0].port)
    error_message = "Service port should be valid"
  }

  assert {
    condition     = can(var.services[0].auth_type)
    error_message = "Service auth type should be valid"
  }

  # Test listener rules validation
  assert {
    condition     = length(var.services[0].listener_rules) > 0
    error_message = "Service should have listener rules"
  }

  assert {
    condition     = can(var.services[0].listener_rules[0].priority)
    error_message = "Listener rule priority should be valid"
  }

  assert {
    condition     = can(var.services[0].listener_rules[0].match.http_match.header_name)
    error_message = "Listener rule header name should be valid"
  }

  assert {
    condition     = can(var.services[0].listener_rules[0].target_group_name)
    error_message = "Listener rule target group name should be valid"
  }

  # Test target group validation
  assert {
    condition     = can(var.services[0].target_groups[0].type)
    error_message = "Target group type should be valid"
  }

  assert {
    condition     = can(var.services[0].target_groups[0].protocol)
    error_message = "Target group protocol should be valid"
  }

  assert {
    condition     = can(var.services[0].target_groups[0].port)
    error_message = "Target group port should be valid"
  }

  # Test health check validation
  assert {
    condition     = can(var.services[0].target_groups[0].health_check.path)
    error_message = "Health check path should be valid"
  }

  assert {
    condition     = can(var.services[0].target_groups[0].health_check.interval)
    error_message = "Health check interval should be valid"
  }

  # Test logging configuration
  assert {
    condition     = var.create_log_group == true
    error_message = "Log group creation should be enabled"
  }

  assert {
    condition     = can(var.log_group_name)
    error_message = "Log group name should be valid"
  }

  assert {
    condition     = can(var.log_retention_days)
    error_message = "Log retention days should be valid"
  }

  # Test VPC association validation
  assert {
    condition     = length(var.vpc_associations) > 0
    error_message = "VPC associations should not be empty"
  }

  assert {
    condition     = can(var.vpc_associations[0].vpc_id)
    error_message = "VPC ID should be valid"
  }
}
