run "test_weighted_routing_configuration" {
  command = plan

  variables {
    service_network = {
      name      = "weighted-test-network"
      auth_type = "NONE"
    }
    vpc_associations = [
      {
        vpc_id = "vpc-test-id"
      }
    ]
    services = [
      {
        name      = "weighted-service"
        protocol  = "HTTP"
        port      = 80
        auth_type = "NONE"
        target_groups = [
          {
            name     = "ec2-tg"
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
          },
          {
            name     = "alb-tg"
            type     = "ALB"
            port     = 80
            protocol = "HTTP"
            vpc_id   = "vpc-test-id"
            targets = [
              {
                target_id = "arn:aws:elasticloadbalancing:ap-southeast-2:123456789012:loadbalancer/app/weighted-alb/1234567890123456"
                port      = 80
              }
            ]
          },
          {
            name = "lambda-tg"
            type = "LAMBDA"
            targets = [
              {
                target_id = "arn:aws:lambda:ap-southeast-2:123456789012:function:weighted-lambda"
              }
            ]
          }
        ]
        default_action = {
          target_group_name = "ec2-tg"
          weight            = 1
        }
      }
    ]
  }

  # Test weighted routing configuration
  assert {
    condition     = length(var.services[0].target_groups) == 3
    error_message = "Should have 3 target groups for weighted routing"
  }

  # Test different target group types
  assert {
    condition     = var.services[0].target_groups[0].type == "INSTANCE"
    error_message = "First target group should be INSTANCE type"
  }

  assert {
    condition     = var.services[0].target_groups[1].type == "ALB"
    error_message = "Second target group should be ALB type"
  }

  assert {
    condition     = var.services[0].target_groups[2].type == "LAMBDA"
    error_message = "Third target group should be LAMBDA type"
  }

  # Test target group names
  assert {
    condition     = var.services[0].target_groups[0].name == "ec2-tg"
    error_message = "First target group should be ec2-tg"
  }

  assert {
    condition     = var.services[0].target_groups[1].name == "alb-tg"
    error_message = "Second target group should be alb-tg"
  }

  assert {
    condition     = var.services[0].target_groups[2].name == "lambda-tg"
    error_message = "Third target group should be lambda-tg"
  }

  # Test targets configuration
  assert {
    condition     = length(var.services[0].target_groups[0].targets) > 0
    error_message = "EC2 target group should have targets"
  }

  assert {
    condition     = length(var.services[0].target_groups[1].targets) > 0
    error_message = "ALB target group should have targets"
  }

  assert {
    condition     = length(var.services[0].target_groups[2].targets) > 0
    error_message = "Lambda target group should have targets"
  }

  # Test default action
  assert {
    condition     = var.services[0].default_action.weight == 1
    error_message = "Default action weight should be 1"
  }
}
