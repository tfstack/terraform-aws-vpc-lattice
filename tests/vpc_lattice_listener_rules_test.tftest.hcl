run "test_listener_rules_configuration" {
  command = plan

  variables {
    service_network = {
      name      = "rules-test-network"
      auth_type = "NONE"
    }
    vpc_associations = [
      {
        vpc_id = "vpc-test-id"
      }
    ]
    services = [
      {
        name      = "api-service"
        protocol  = "HTTP"
        port      = 80
        auth_type = "NONE"
        target_groups = [
          {
            name = "products-tg"
            type = "LAMBDA"
            targets = [
              {
                target_id = "arn:aws:lambda:ap-southeast-2:123456789012:function:products"
              }
            ]
          },
          {
            name = "orders-tg"
            type = "LAMBDA"
            targets = [
              {
                target_id = "arn:aws:lambda:ap-southeast-2:123456789012:function:orders"
              }
            ]
          },
          {
            name = "notfound-tg"
            type = "LAMBDA"
            targets = [
              {
                target_id = "arn:aws:lambda:ap-southeast-2:123456789012:function:notfound"
              }
            ]
          }
        ]
        listener_rules = [
          {
            priority          = 10
            target_group_name = "products-tg"
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
            }
          },
          {
            priority          = 20
            target_group_name = "orders-tg"
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
            }
          }
        ]
        default_action = {
          target_group_name = "notfound-tg"
          weight            = 1
        }
      }
    ]
  }

  # Test listener rules configuration
  assert {
    condition     = length(var.services[0].listener_rules) == 2
    error_message = "Should have 2 listener rules"
  }

  # Test first rule (products)
  assert {
    condition     = var.services[0].listener_rules[0].priority == 10
    error_message = "First rule priority should be 10"
  }

  assert {
    condition     = var.services[0].listener_rules[0].target_group_name == "products-tg"
    error_message = "First rule target group should be products-tg"
  }

  assert {
    condition     = var.services[0].listener_rules[0].match.http_match.path == "/products"
    error_message = "First rule path should be /products"
  }

  assert {
    condition     = var.services[0].listener_rules[0].action.weight == 1
    error_message = "First rule weight should be 1"
  }

  # Test second rule (orders)
  assert {
    condition     = var.services[0].listener_rules[1].priority == 20
    error_message = "Second rule priority should be 20"
  }

  assert {
    condition     = var.services[0].listener_rules[1].target_group_name == "orders-tg"
    error_message = "Second rule target group should be orders-tg"
  }

  assert {
    condition     = var.services[0].listener_rules[1].match.http_match.path == "/orders"
    error_message = "Second rule path should be /orders"
  }

  # Test default action
  assert {
    condition     = var.services[0].default_action.target_group_name == "notfound-tg"
    error_message = "Default action target group should be notfound-tg"
  }

  assert {
    condition     = var.services[0].default_action.weight == 1
    error_message = "Default action weight should be 1"
  }

  # Test target groups
  assert {
    condition     = length(var.services[0].target_groups) == 3
    error_message = "Should have 3 target groups"
  }

  assert {
    condition     = var.services[0].target_groups[0].name == "products-tg"
    error_message = "First target group should be products-tg"
  }

  assert {
    condition     = var.services[0].target_groups[1].name == "orders-tg"
    error_message = "Second target group should be orders-tg"
  }

  assert {
    condition     = var.services[0].target_groups[2].name == "notfound-tg"
    error_message = "Third target group should be notfound-tg"
  }
}
