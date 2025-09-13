run "test_service_network_auth_policy" {
  command = plan

  variables {
    service_network = {
      name      = "auth-policy-network"
      auth_type = "AWS_IAM"
      auth_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Principal = {
              AWS = "arn:aws:iam::123456789012:root"
            }
            Action   = ["vpc-lattice-svcs:Invoke"]
            Resource = "*"
            Condition = {
              StringEquals = {
                "aws:PrincipalTag/Environment" : "prod"
              }
            }
          }
        ]
      })
    }
    vpc_associations = [
      {
        vpc_id = "vpc-test-id"
      }
    ]
    services = [
      {
        name      = "auth-service"
        protocol  = "HTTP"
        port      = 80
        auth_type = "AWS_IAM"
        target_groups = [
          {
            name = "auth-tg"
            type = "LAMBDA"
            targets = [
              {
                target_id = "arn:aws:lambda:ap-southeast-2:123456789012:function:auth-lambda"
              }
            ]
          }
        ]
        default_action = {
          target_group_name = "auth-tg"
          weight            = 1
        }
      }
    ]
  }

  # Test service network auth policy configuration
  assert {
    condition     = var.service_network.auth_policy != null
    error_message = "Service network should have auth policy"
  }

  assert {
    condition     = var.service_network.auth_type == "AWS_IAM"
    error_message = "Service network auth type should be AWS_IAM"
  }

  # Test auth policy JSON structure
  assert {
    condition     = can(jsondecode(var.service_network.auth_policy))
    error_message = "Service network auth policy should be valid JSON"
  }

  # Test service auth type
  assert {
    condition     = var.services[0].auth_type == "AWS_IAM"
    error_message = "Service auth type should be AWS_IAM"
  }
}

run "test_service_level_auth_policy" {
  command = plan

  variables {
    service_network = {
      name      = "service-auth-network"
      auth_type = "NONE"
    }
    vpc_associations = [
      {
        vpc_id = "vpc-test-id"
      }
    ]
    services = [
      {
        name      = "admin-service"
        protocol  = "HTTP"
        port      = 80
        auth_type = "AWS_IAM"
        auth_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Principal = {
                AWS = "arn:aws:iam::123456789012:role/AdminRole"
              }
              Action   = ["vpc-lattice-svcs:Invoke"]
              Resource = "*"
              Condition = {
                StringLike = {
                  "aws:PrincipalArn" : "arn:aws:iam::123456789012:role/*admin*"
                }
              }
            }
          ]
        })
        target_groups = [
          {
            name = "admin-tg"
            type = "LAMBDA"
            targets = [
              {
                target_id = "arn:aws:lambda:ap-southeast-2:123456789012:function:admin-lambda"
              }
            ]
          }
        ]
        default_action = {
          target_group_name = "admin-tg"
          weight            = 1
        }
      },
      {
        name      = "public-service"
        protocol  = "HTTP"
        port      = 80
        auth_type = "NONE"
        target_groups = [
          {
            name = "public-tg"
            type = "LAMBDA"
            targets = [
              {
                target_id = "arn:aws:lambda:ap-southeast-2:123456789012:function:public-lambda"
              }
            ]
          }
        ]
        default_action = {
          target_group_name = "public-tg"
          weight            = 1
        }
      }
    ]
  }

  # Test mixed auth types
  assert {
    condition     = var.service_network.auth_type == "NONE"
    error_message = "Service network auth type should be NONE"
  }

  assert {
    condition     = var.services[0].auth_type == "AWS_IAM"
    error_message = "First service auth type should be AWS_IAM"
  }

  assert {
    condition     = var.services[1].auth_type == "NONE"
    error_message = "Second service auth type should be NONE"
  }

  # Test service-level auth policy
  assert {
    condition     = var.services[0].auth_policy != null
    error_message = "Admin service should have auth policy"
  }

  assert {
    condition     = var.services[1].auth_policy == null
    error_message = "Public service should not have auth policy"
  }

  # Test auth policy JSON structure
  assert {
    condition     = can(jsondecode(var.services[0].auth_policy))
    error_message = "Service auth policy should be valid JSON"
  }
}
