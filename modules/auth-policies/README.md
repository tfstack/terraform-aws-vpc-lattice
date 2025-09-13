# VPC Lattice Auth Policies Submodule

This submodule manages VPC Lattice authentication policies for services. It provides a clean way to apply custom authentication policies to VPC Lattice services without cluttering the main module.

## Features

- **Conditional Policy Creation**: Only creates auth policies for services that specify them
- **Flexible Policy Input**: Accepts JSON policy strings for maximum customization
- **Clean Integration**: Works seamlessly with the main VPC Lattice module

## Usage

```terraform
module "vpc_lattice_auth" {
  source = "./modules/auth-policies"

  services = module.vpc_lattice.services
  service_arns = module.vpc_lattice.service_arns
  tags = var.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| services | Map of VPC Lattice services with their configurations | `map(object)` | n/a | yes |
| service_arns | Map of service names to their ARNs | `map(string)` | n/a | yes |
| tags | Default tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| auth_policy_ids | IDs of the created auth policies |
| auth_policy_arns | ARNs of the created auth policies |
| custom_policy_services | List of services that have custom auth policies |

## Service Configuration

To enable a custom auth policy for a service, add an `auth_policy` field to the service configuration:

```terraform
services = [
  {
    name = "admin-tools"
    # ... other service config ...
    auth_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          }
          Action = ["vpc-lattice-svcs:Invoke"]
          Resource = "*"
          Condition = {
            StringEquals = {
              "aws:PrincipalTag/Environment": "prod"
            }
            StringLike = {
              "aws:PrincipalArn": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*admin*"
            }
          }
        }
      ]
    })
  }
]
```

## Notes

- Only services with `auth_policy` specified will have policies created
- The `auth_policy` should be a valid JSON policy document
- Policies are applied to the service ARN from the main module
- This submodule is optional and can be omitted if no custom policies are needed
