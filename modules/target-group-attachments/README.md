# Target Group Attachments Module

This module handles the creation and management of VPC Lattice target group attachments.

## Features

- Creates target group attachments for VPC Lattice target groups
- Supports multiple target types (ALB, Instance, IP, Lambda)
- Handles target port configuration
- Manages lifecycle and timeouts for attachments

## Usage

```hcl
module "target_group_attachments" {
  source = "./modules/target-group-attachments"

  target_groups = {
    for service in var.services : service.target_group.name => service.target_group
  }

  target_group_ids = module.target_groups.target_group_ids
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `target_groups` | Map of target group configurations | `map(object)` | n/a | yes |
| `target_group_ids` | Map of target group names to IDs | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| `target_group_attachments` | Map of target group attachment names to full attachment objects |
| `attachment_ids` | Map of target group attachment names to IDs |
