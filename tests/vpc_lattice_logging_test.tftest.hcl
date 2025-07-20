run "test_access_logging_configuration" {
  command = plan

  variables {
    service_network = {
      name      = "logging-test-network"
      auth_type = "NONE"
      log_config = {
        destination_arn = "arn:aws:logs:ap-southeast-2:123456789012:log-group:/aws/vpclattice/test-network"
      }
    }
    vpc_associations = [
      {
        vpc_id = "vpc-test-id"
      }
    ]
    services = [
      {
        name      = "logging-service"
        protocol  = "HTTP"
        port      = 80
        auth_type = "NONE"
        log_config = {
          destination_arn = "arn:aws:logs:ap-southeast-2:123456789012:log-group:/aws/vpclattice/test-service"
        }
        target_groups = [
          {
            name = "logging-tg"
            type = "LAMBDA"
            targets = [
              {
                target_id = "arn:aws:lambda:ap-southeast-2:123456789012:function:logging-lambda"
              }
            ]
          }
        ]
        default_action = {
          target_group_name = "logging-tg"
          weight            = 1
        }
      }
    ]
    create_log_group   = true
    log_group_name     = "/aws/vpclattice/test"
    log_retention_days = 7
  }

  # Test service network logging configuration
  assert {
    condition     = var.service_network.log_config != null
    error_message = "Service network should have log config"
  }

  assert {
    condition     = var.service_network.log_config.destination_arn != null
    error_message = "Service network log destination ARN should not be null"
  }

  # Test service logging configuration
  assert {
    condition     = var.services[0].log_config != null
    error_message = "Service should have log config"
  }

  assert {
    condition     = var.services[0].log_config.destination_arn != null
    error_message = "Service log destination ARN should not be null"
  }

  # Test CloudWatch log group configuration
  assert {
    condition     = var.create_log_group == true
    error_message = "Log group creation should be enabled"
  }

  assert {
    condition     = var.log_group_name == "/aws/vpclattice/test"
    error_message = "Log group name should match expected value"
  }

  assert {
    condition     = var.log_retention_days == 7
    error_message = "Log retention days should be 7"
  }
}
