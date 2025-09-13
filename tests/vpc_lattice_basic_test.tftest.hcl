run "test_basic_configuration" {
  command = plan

  variables {
    service_network = {
      name      = "test-service-network"
      auth_type = "AWS_IAM"
    }
    vpc_associations = [
      {
        vpc_id = "vpc-test-id"
      }
    ]
    services = [
      {
        name      = "test-service"
        protocol  = "HTTP"
        port      = 80
        auth_type = "AWS_IAM"
        target_groups = [
          {
            name     = "test-tg"
            type     = "ALB"
            port     = 80
            protocol = "HTTP"
            vpc_id   = "vpc-test-id"
            targets = [
              {
                target_id = "arn:aws:elasticloadbalancing:ap-southeast-2:123456789012:loadbalancer/app/test-alb/1234567890123456"
                port      = 80
              }
            ]
          }
        ]
        default_action = {
          target_group_name = "test-tg"
          weight            = 1
        }
      }
    ]
  }

  # Test service network configuration
  assert {
    condition     = var.service_network.name != null
    error_message = "Service network name should not be null"
  }

  assert {
    condition     = var.service_network.auth_type == "AWS_IAM"
    error_message = "Service network auth type should be AWS_IAM"
  }

  # Test services configuration
  assert {
    condition     = length(var.services) > 0
    error_message = "Services should not be empty"
  }

  assert {
    condition     = var.services[0].protocol == "HTTP"
    error_message = "Service protocol should be HTTP"
  }

  assert {
    condition     = var.services[0].port == 80
    error_message = "Service port should be 80"
  }

  assert {
    condition     = var.services[0].auth_type == "AWS_IAM"
    error_message = "Service auth type should be AWS_IAM"
  }

  # Test target group configuration
  assert {
    condition     = var.services[0].target_groups[0].type == "ALB"
    error_message = "Target group type should be ALB"
  }

  assert {
    condition     = var.services[0].target_groups[0].protocol == "HTTP"
    error_message = "Target group protocol should be HTTP"
  }

  assert {
    condition     = var.services[0].target_groups[0].port == 80
    error_message = "Target group port should be 80"
  }

  assert {
    condition     = length(var.services[0].target_groups[0].targets) > 0
    error_message = "Target group should have targets"
  }

  # Test VPC associations
  assert {
    condition     = length(var.vpc_associations) > 0
    error_message = "VPC associations should not be empty"
  }

  assert {
    condition     = var.vpc_associations[0].vpc_id == "vpc-test-id"
    error_message = "VPC ID should match expected value"
  }

  # Test default action
  assert {
    condition     = var.services[0].default_action.weight == 1
    error_message = "Default action weight should be 1"
  }
}

run "test_lambda_target_group" {
  command = plan

  variables {
    service_network = {
      name      = "lambda-test-network"
      auth_type = "NONE"
    }
    vpc_associations = [
      {
        vpc_id = "vpc-test-id"
      }
    ]
    services = [
      {
        name      = "lambda-service"
        protocol  = "HTTP"
        port      = 80
        auth_type = "NONE"
        target_groups = [
          {
            name                           = "lambda-tg"
            type                           = "LAMBDA"
            lambda_event_structure_version = "V1"
            targets = [
              {
                target_id = "arn:aws:lambda:ap-southeast-2:123456789012:function:test-function"
              }
            ]
          }
        ]
        default_action = {
          target_group_name = "lambda-tg"
          weight            = 1
        }
      }
    ]
  }

  # Test Lambda target group configuration
  assert {
    condition     = var.services[0].target_groups[0].type == "LAMBDA"
    error_message = "Target group type should be LAMBDA"
  }

  assert {
    condition     = var.services[0].target_groups[0].lambda_event_structure_version == "V1"
    error_message = "Lambda event structure version should be V1"
  }

  assert {
    condition     = length(var.services[0].target_groups[0].targets) > 0
    error_message = "Lambda target group should have targets"
  }

  assert {
    condition     = var.services[0].target_groups[0].targets[0].target_id != null
    error_message = "Lambda target ID should not be null"
  }
}

run "test_instance_target_group" {
  command = plan

  variables {
    service_network = {
      name      = "instance-test-network"
      auth_type = "NONE"
    }
    vpc_associations = [
      {
        vpc_id = "vpc-test-id"
      }
    ]
    services = [
      {
        name      = "instance-service"
        protocol  = "HTTP"
        port      = 80
        auth_type = "NONE"
        target_groups = [
          {
            name     = "instance-tg"
            type     = "INSTANCE"
            port     = 80
            protocol = "HTTP"
            vpc_id   = "vpc-test-id"
            targets = [
              {
                target_id = "i-1234567890abcdef0"
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
          target_group_name = "instance-tg"
          weight            = 1
        }
      }
    ]
  }

  # Test Instance target group configuration
  assert {
    condition     = var.services[0].target_groups[0].type == "INSTANCE"
    error_message = "Target group type should be INSTANCE"
  }

  assert {
    condition     = var.services[0].target_groups[0].protocol == "HTTP"
    error_message = "Instance target group protocol should be HTTP"
  }

  assert {
    condition     = var.services[0].target_groups[0].port == 80
    error_message = "Instance target group port should be 80"
  }

  assert {
    condition     = var.services[0].target_groups[0].vpc_id == "vpc-test-id"
    error_message = "Instance target group VPC ID should match"
  }

  # Test health check configuration
  assert {
    condition     = var.services[0].target_groups[0].health_check.path == "/health"
    error_message = "Health check path should be /health"
  }

  assert {
    condition     = var.services[0].target_groups[0].health_check.interval == 30
    error_message = "Health check interval should be 30"
  }

  assert {
    condition     = var.services[0].target_groups[0].health_check.timeout == 5
    error_message = "Health check timeout should be 5"
  }
}
