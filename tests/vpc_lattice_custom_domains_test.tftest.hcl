run "test_custom_domains_configuration" {
  command = plan

  variables {
    service_network = {
      name      = "custom-domain-network"
      auth_type = "NONE"
    }
    vpc_associations = [
      {
        vpc_id = "vpc-test-id"
      }
    ]
    services = [
      {
        name        = "api-service"
        protocol    = "HTTP"
        port        = 80
        auth_type   = "NONE"
        custom_name = "api.example.local"
        target_groups = [
          {
            name = "api-tg"
            type = "LAMBDA"
            targets = [
              {
                target_id = "arn:aws:lambda:ap-southeast-2:123456789012:function:api-lambda"
              }
            ]
          }
        ]
        default_action = {
          target_group_name = "api-tg"
          weight            = 1
        }
      },
      {
        name        = "web-service"
        protocol    = "HTTP"
        port        = 80
        auth_type   = "NONE"
        custom_name = "web.example.local"
        target_groups = [
          {
            name     = "web-tg"
            type     = "ALB"
            port     = 80
            protocol = "HTTP"
            vpc_id   = "vpc-test-id"
            targets = [
              {
                target_id = "arn:aws:elasticloadbalancing:ap-southeast-2:123456789012:loadbalancer/app/web/1234567890123456"
                port      = 80
              }
            ]
          }
        ]
        default_action = {
          target_group_name = "web-tg"
          weight            = 1
        }
      }
    ]
    create_route53_zone = true
    route53_zone_name   = "example.local"
  }

  # Test custom domain configuration
  assert {
    condition     = var.services[0].custom_name == "api.example.local"
    error_message = "First service should have custom name api.example.local"
  }

  assert {
    condition     = var.services[1].custom_name == "web.example.local"
    error_message = "Second service should have custom name web.example.local"
  }

  # Test Route 53 zone configuration
  assert {
    condition     = var.create_route53_zone == true
    error_message = "Route 53 zone creation should be enabled"
  }

  assert {
    condition     = var.route53_zone_name == "example.local"
    error_message = "Route 53 zone name should be example.local"
  }

  # Test services without custom domains
  assert {
    condition     = length(var.services) == 2
    error_message = "Should have 2 services"
  }

  # Test different target group types with custom domains
  assert {
    condition     = var.services[0].target_groups[0].type == "LAMBDA"
    error_message = "API service target group should be LAMBDA type"
  }

  assert {
    condition     = var.services[1].target_groups[0].type == "ALB"
    error_message = "Web service target group should be ALB type"
  }
}
