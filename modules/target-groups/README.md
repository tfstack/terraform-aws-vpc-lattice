# Target Groups Submodule

This submodule manages VPC Lattice target groups and their attachments with proper lifecycle management to avoid race conditions during destruction.

## Features

- **Race Condition Prevention**: Uses simplified lifecycle rules to avoid `HealthCheckNotSupported` and `TargetGroupNotInUse` errors
- **Flexible Target Types**: Supports ALB, INSTANCE, IP, and LAMBDA target types
- **Clean Dependencies**: No forced dependencies that cause timing issues
- **Proper Cleanup**: Ensures attachments are cleaned up before target groups

## Usage

```hcl
module "target_groups" {
  source = "./modules/target-groups"

  target_groups = {
    "web-target" = {
      name     = "web-target"
      type     = "ALB"
      protocol = "HTTP"
      port     = 80
      vpc_id   = module.vpc.vpc_id
      targets = [
        {
          target_id = module.alb.arn
          port      = 80
        }
      ]
      tags = {
        Environment = "production"
      }
    }
  }

  tags = {
    Project = "my-app"
  }
}
```

## Outputs

- `target_group_ids`: Map of target group names to IDs
- `target_group_arns`: Map of target group names to ARNs
- `target_group_attachments`: Full attachment objects for debugging
