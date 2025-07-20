# Listeners Submodule

This submodule manages VPC Lattice listeners and listener rules with proper dependency management.

## Features

- **Clean Dependencies**: No forced dependencies that cause timing issues
- **Flexible Rules**: Supports HTTP header and path-based routing
- **Proper Cleanup**: Ensures listeners and rules are cleaned up in the right order
- **Reusable**: Can be used across different VPC Lattice configurations

## Usage

```hcl
module "listeners" {
  source = "./modules/listeners"

  listeners = {
    "web-service" = {
      name                    = "web-service"
      protocol                = "HTTP"
      port                    = 80
      service_identifier      = module.services.service_ids["web-service"]
      target_group_identifier = module.target_groups.target_group_ids["web-target"]
      default_action = {
        weight = 1
      }
      tags = {
        Environment = "production"
      }
    }
  }

  listener_rules = [
    {
      service_name           = "web-service"
      priority               = 100
      service_identifier     = module.services.service_ids["web-service"]
      target_group_identifier = module.target_groups.target_group_ids["api-target"]
      match = {
        http_match = {
          header_name  = "X-Route"
          header_value = "api"
          path         = "/api/*"
        }
      }
      action = {
        weight = 1
      }
      tags = {
        Type = "api-route"
      }
    }
  ]

  tags = {
    Project = "my-app"
  }
}
```

## Outputs

- `listener_ids`: Map of listener names to IDs
- `listener_arns`: Map of listener names to ARNs
- `listener_rules`: Full rule objects for debugging
