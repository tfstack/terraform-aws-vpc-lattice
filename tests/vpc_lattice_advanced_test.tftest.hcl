run "advanced_vpc_lattice" {
  command = plan

  variables {
    service_network = {
      name      = "advanced-test-network"
      auth_type = "AWS_IAM"
    }
    vpc_associations = [
      {
        vpc_id = "vpc-test-id"
      }
    ]
    services = [
      {
        name      = "user-service"
        protocol  = "HTTP"
        port      = 80
        auth_type = "AWS_IAM"
        target_groups = [
          {
            name     = "user-tg"
            type     = "ALB"
            port     = 80
            protocol = "HTTP"
            vpc_id   = "vpc-test-id"
            targets = [
              {
                target_id = "arn:aws:elasticloadbalancing:ap-southeast-2:123456789012:loadbalancer/app/user-alb/1234567890123456"
                port      = 80
              }
            ]
          }
        ]
        default_action = {
          target_group_name = "user-tg"
          weight            = 1
        }
      },
      {
        name      = "order-service"
        protocol  = "HTTP"
        port      = 80
        auth_type = "AWS_IAM"
        target_groups = [
          {
            name     = "order-tg"
            type     = "ALB"
            port     = 80
            protocol = "HTTP"
            vpc_id   = "vpc-test-id"
            targets = [
              {
                target_id = "arn:aws:elasticloadbalancing:ap-southeast-2:123456789012:loadbalancer/app/order-alb/1234567890123456"
                port      = 80
              }
            ]
          }
        ]
        default_action = {
          target_group_name = "order-tg"
          weight            = 1
        }
      },
      {
        name      = "payment-service"
        protocol  = "HTTPS"
        port      = 443
        auth_type = "AWS_IAM"
        target_groups = [
          {
            name = "payment-tg"
            type = "LAMBDA"
            targets = [
              {
                target_id = "arn:aws:lambda:ap-southeast-2:123456789012:function:payment-processor"
              }
            ]
          }
        ]
        default_action = {
          target_group_name = "payment-tg"
          weight            = 1
        }
      }
    ]
  }

  # Test service network
  assert {
    condition     = var.service_network.name == "advanced-test-network"
    error_message = "Service network name should match expected value"
  }

  assert {
    condition     = var.service_network.auth_type == "AWS_IAM"
    error_message = "Service network auth type should be AWS_IAM"
  }

  # Test VPC associations
  assert {
    condition     = length(var.vpc_associations) == 1
    error_message = "Should have 1 VPC association"
  }

  assert {
    condition     = var.vpc_associations[0].vpc_id == "vpc-test-id"
    error_message = "VPC ID should match expected value"
  }

  # Test services
  assert {
    condition     = length(var.services) == 3
    error_message = "Should have 3 services"
  }

  # Test service configurations
  assert {
    condition     = var.services[0].name == "user-service"
    error_message = "First service should be user-service"
  }

  assert {
    condition     = var.services[1].name == "order-service"
    error_message = "Second service should be order-service"
  }

  assert {
    condition     = var.services[2].name == "payment-service"
    error_message = "Third service should be payment-service"
  }

  assert {
    condition     = var.services[0].protocol == "HTTP"
    error_message = "User service protocol should be HTTP"
  }

  assert {
    condition     = var.services[1].protocol == "HTTP"
    error_message = "Order service protocol should be HTTP"
  }

  assert {
    condition     = var.services[2].protocol == "HTTPS"
    error_message = "Payment service protocol should be HTTPS"
  }

  assert {
    condition     = var.services[0].port == 80
    error_message = "User service port should be 80"
  }

  assert {
    condition     = var.services[1].port == 80
    error_message = "Order service port should be 80"
  }

  assert {
    condition     = var.services[2].port == 443
    error_message = "Payment service port should be 443"
  }

  # Test target group configurations
  assert {
    condition     = var.services[0].target_groups[0].type == "ALB"
    error_message = "User target group type should be ALB"
  }

  assert {
    condition     = var.services[1].target_groups[0].type == "ALB"
    error_message = "Order target group type should be ALB"
  }

  assert {
    condition     = var.services[2].target_groups[0].type == "LAMBDA"
    error_message = "Payment target group type should be LAMBDA"
  }

  assert {
    condition     = var.services[0].target_groups[0].protocol == "HTTP"
    error_message = "User target group protocol should be HTTP"
  }

  assert {
    condition     = var.services[1].target_groups[0].protocol == "HTTP"
    error_message = "Order target group protocol should be HTTP"
  }

  # Test target configurations
  assert {
    condition     = length(var.services[0].target_groups[0].targets) > 0
    error_message = "User target group should have targets"
  }

  assert {
    condition     = length(var.services[1].target_groups[0].targets) > 0
    error_message = "Order target group should have targets"
  }

  assert {
    condition     = length(var.services[2].target_groups[0].targets) > 0
    error_message = "Payment target group should have targets"
  }

  # Test VPC associations
  assert {
    condition     = length(var.vpc_associations) > 0
    error_message = "VPC associations should not be empty"
  }

  assert {
    condition     = can(var.vpc_associations[0].vpc_id)
    error_message = "VPC ID should be valid"
  }
}
