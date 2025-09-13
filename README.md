# Terraform AWS VPC Lattice Module

Terraform module for secure service-to-service communication across VPCs using AWS VPC Lattice

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_auth_policies"></a> [auth\_policies](#module\_auth\_policies) | ./modules/auth-policies | n/a |
| <a name="module_listeners"></a> [listeners](#module\_listeners) | ./modules/listeners | n/a |
| <a name="module_target_group_attachments"></a> [target\_group\_attachments](#module\_target\_group\_attachments) | ./modules/target-group-attachments | n/a |
| <a name="module_target_groups"></a> [target\_groups](#module\_target\_groups) | ./modules/target-groups | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.lattice_logs_protected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.lattice_logs_unprotected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.resource_access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.service_access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.service_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.service_network_access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_route53_record.service_cnames](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.custom_domains](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_vpclattice_access_log_subscription.resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_access_log_subscription) | resource |
| [aws_vpclattice_access_log_subscription.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_access_log_subscription) | resource |
| [aws_vpclattice_access_log_subscription.service_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_access_log_subscription) | resource |
| [aws_vpclattice_auth_policy.service_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_auth_policy) | resource |
| [aws_vpclattice_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service) | resource |
| [aws_vpclattice_service_network.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network) | resource |
| [aws_vpclattice_service_network_service_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network_service_association) | resource |
| [aws_vpclattice_service_network_vpc_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network_vpc_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_log_group"></a> [create\_log\_group](#input\_create\_log\_group) | Whether to create a CloudWatch log group for VPC Lattice logs | `bool` | `false` | no |
| <a name="input_create_per_service_log_groups"></a> [create\_per\_service\_log\_groups](#input\_create\_per\_service\_log\_groups) | Whether to create individual CloudWatch log groups for each service | `bool` | `false` | no |
| <a name="input_create_route53_zone"></a> [create\_route53\_zone](#input\_create\_route53\_zone) | Whether to create a Route 53 zone for custom domains | `bool` | `false` | no |
| <a name="input_create_service_network"></a> [create\_service\_network](#input\_create\_service\_network) | Whether to create a new service network or use existing one | `bool` | `true` | no |
| <a name="input_enable_resource_access_logs"></a> [enable\_resource\_access\_logs](#input\_enable\_resource\_access\_logs) | Whether to enable resource access logs for VPC Lattice resources (API calls, management operations) | `bool` | `false` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | Name of the CloudWatch log group for VPC Lattice logs | `string` | `"/aws/vpclattice"` | no |
| <a name="input_log_group_name_prefix"></a> [log\_group\_name\_prefix](#input\_log\_group\_name\_prefix) | Prefix for CloudWatch log group names to avoid conflicts when multiple module instances are used | `string` | `"/aws/vpclattice"` | no |
| <a name="input_log_group_prevent_destroy"></a> [log\_group\_prevent\_destroy](#input\_log\_group\_prevent\_destroy) | Whether to prevent destruction of the CloudWatch log group | `bool` | `true` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain CloudWatch logs | `number` | `7` | no |
| <a name="input_resource_log_group_name_prefix"></a> [resource\_log\_group\_name\_prefix](#input\_resource\_log\_group\_name\_prefix) | Prefix for resource access log group names | `string` | `null` | no |
| <a name="input_route53_vpc_ids"></a> [route53\_vpc\_ids](#input\_route53\_vpc\_ids) | List of VPC IDs to associate with the Route 53 zone | `list(string)` | `[]` | no |
| <a name="input_route53_zone_name"></a> [route53\_zone\_name](#input\_route53\_zone\_name) | Name of the Route 53 zone to create (e.g., 'internal') | `string` | `null` | no |
| <a name="input_route53_zone_tags"></a> [route53\_zone\_tags](#input\_route53\_zone\_tags) | Tags for the Route 53 zone | `map(string)` | `{}` | no |
| <a name="input_service_log_group_name_prefix"></a> [service\_log\_group\_name\_prefix](#input\_service\_log\_group\_name\_prefix) | Prefix for service-specific log group names | `string` | `null` | no |
| <a name="input_service_network"></a> [service\_network](#input\_service\_network) | Configuration for the VPC Lattice service network | <pre>object({<br/>    name      = string<br/>    auth_type = string<br/>    log_config = optional(object({<br/>      destination_arn = optional(string)<br/>    }))<br/>    auth_policy = optional(string)<br/>    tags        = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_service_network_id"></a> [service\_network\_id](#input\_service\_network\_id) | ID of existing service network to use when create\_service\_network is false | `string` | `null` | no |
| <a name="input_service_network_log_group_name"></a> [service\_network\_log\_group\_name](#input\_service\_network\_log\_group\_name) | Name for the service network access log group (defaults to using log\_group\_name\_prefix + service network name) | `string` | `null` | no |
| <a name="input_services"></a> [services](#input\_services) | List of VPC Lattice services with their associated target groups | <pre>list(object({<br/>    name      = string<br/>    protocol  = string<br/>    port      = number<br/>    auth_type = string<br/><br/>    # Native VPC Lattice custom domain support<br/>    custom_name = optional(string)<br/><br/>    # Target groups for weighted routing<br/>    target_groups = list(object({<br/>      name                           = string<br/>      type                           = string<br/>      protocol                       = optional(string) # Required for INSTANCE/ALB/IP, optional for LAMBDA<br/>      port                           = optional(number) # Required for INSTANCE/ALB/IP, optional for LAMBDA<br/>      vpc_id                         = optional(string) # Required for INSTANCE/ALB/IP, optional for LAMBDA<br/>      weight                         = optional(number, 1)<br/>      lambda_event_structure_version = optional(string, "V1")<br/>      targets = optional(list(object({<br/>        target_id = string<br/>        port      = optional(number)<br/>      })), [])<br/>      health_check = optional(object({<br/>        path                = string<br/>        interval            = optional(number, 30)<br/>        timeout             = optional(number, 5)<br/>        healthy_threshold   = optional(number, 2)<br/>        unhealthy_threshold = optional(number, 2)<br/>      }))<br/>      tags = optional(map(string), {})<br/>    }))<br/><br/>    # Service-specific configuration<br/>    default_action = optional(object({<br/>      target_group_name = string<br/>      weight            = optional(number, 1)<br/>    }))<br/>    listener_rules = optional(list(object({<br/>      priority          = number<br/>      target_group_name = optional(string) # Allow rules to specify which target group to route to<br/>      match = optional(object({<br/>        http_match = optional(object({<br/>          header_name     = optional(string)<br/>          header_value    = optional(string)<br/>          method          = optional(string)<br/>          path            = string<br/>          path_match_type = optional(string, "exact") # exact, prefix<br/>        }))<br/>      }))<br/>      action = optional(object({<br/>        weight = optional(number, 1)<br/>      }))<br/>      tags = optional(map(string), {})<br/>    })), [])<br/><br/>    # Auth policy configuration (optional - for custom policies)<br/>    auth_policy = optional(string)<br/><br/>    # Access logging configuration (optional)<br/>    log_config = optional(object({<br/>      destination_arn = optional(string)<br/>    }))<br/><br/>    tags = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags for all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_associations"></a> [vpc\_associations](#input\_vpc\_associations) | List of VPCs to associate with the service network | <pre>list(object({<br/>    vpc_id             = string<br/>    security_group_ids = optional(list(string))<br/>    tags               = optional(map(string), {})<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auth_policy_arns"></a> [auth\_policy\_arns](#output\_auth\_policy\_arns) | ARNs of the created auth policies |
| <a name="output_auth_policy_ids"></a> [auth\_policy\_ids](#output\_auth\_policy\_ids) | IDs of the created auth policies |
| <a name="output_custom_domain_names"></a> [custom\_domain\_names](#output\_custom\_domain\_names) | Custom domain names configured for VPC Lattice services |
| <a name="output_listener_arns"></a> [listener\_arns](#output\_listener\_arns) | ARNs of the listeners |
| <a name="output_listener_ids"></a> [listener\_ids](#output\_listener\_ids) | IDs of the listeners |
| <a name="output_listener_rules"></a> [listener\_rules](#output\_listener\_rules) | Listener rules |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | ARN of the CloudWatch log group for VPC Lattice logs |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name of the CloudWatch log group for VPC Lattice logs |
| <a name="output_per_service_log_group_arns"></a> [per\_service\_log\_group\_arns](#output\_per\_service\_log\_group\_arns) | ARNs of the per-service CloudWatch log groups |
| <a name="output_per_service_log_group_names"></a> [per\_service\_log\_group\_names](#output\_per\_service\_log\_group\_names) | Names of the per-service CloudWatch log groups |
| <a name="output_resource_access_log_group_arns"></a> [resource\_access\_log\_group\_arns](#output\_resource\_access\_log\_group\_arns) | ARNs of the resource access log groups |
| <a name="output_resource_access_log_group_names"></a> [resource\_access\_log\_group\_names](#output\_resource\_access\_log\_group\_names) | Names of the resource access log groups |
| <a name="output_resource_access_log_subscription_arns"></a> [resource\_access\_log\_subscription\_arns](#output\_resource\_access\_log\_subscription\_arns) | ARNs of the resource access log subscriptions |
| <a name="output_resource_access_log_subscription_ids"></a> [resource\_access\_log\_subscription\_ids](#output\_resource\_access\_log\_subscription\_ids) | IDs of the resource access log subscriptions |
| <a name="output_route53_cname_records"></a> [route53\_cname\_records](#output\_route53\_cname\_records) | CNAME records created for VPC Lattice services with custom domains |
| <a name="output_route53_zone_id"></a> [route53\_zone\_id](#output\_route53\_zone\_id) | ID of the Route 53 zone created for custom domains |
| <a name="output_route53_zone_name"></a> [route53\_zone\_name](#output\_route53\_zone\_name) | Name of the Route 53 zone created for custom domains |
| <a name="output_route53_zone_name_servers"></a> [route53\_zone\_name\_servers](#output\_route53\_zone\_name\_servers) | Name servers for the Route 53 zone |
| <a name="output_service_access_log_group_arns"></a> [service\_access\_log\_group\_arns](#output\_service\_access\_log\_group\_arns) | ARNs of the service access log groups |
| <a name="output_service_access_log_group_names"></a> [service\_access\_log\_group\_names](#output\_service\_access\_log\_group\_names) | Names of the service access log groups |
| <a name="output_service_access_log_subscription_arns"></a> [service\_access\_log\_subscription\_arns](#output\_service\_access\_log\_subscription\_arns) | ARNs of the service access log subscriptions |
| <a name="output_service_access_log_subscription_ids"></a> [service\_access\_log\_subscription\_ids](#output\_service\_access\_log\_subscription\_ids) | IDs of the service access log subscriptions |
| <a name="output_service_arns"></a> [service\_arns](#output\_service\_arns) | ARNs of the VPC Lattice services |
| <a name="output_service_dns_entries"></a> [service\_dns\_entries](#output\_service\_dns\_entries) | DNS entries for the VPC Lattice services |
| <a name="output_service_ids"></a> [service\_ids](#output\_service\_ids) | IDs of the VPC Lattice services |
| <a name="output_service_names"></a> [service\_names](#output\_service\_names) | Names of the VPC Lattice services |
| <a name="output_service_network_access_log_group_arn"></a> [service\_network\_access\_log\_group\_arn](#output\_service\_network\_access\_log\_group\_arn) | ARN of the service network access log group |
| <a name="output_service_network_access_log_group_name"></a> [service\_network\_access\_log\_group\_name](#output\_service\_network\_access\_log\_group\_name) | Name of the service network access log group |
| <a name="output_service_network_arn"></a> [service\_network\_arn](#output\_service\_network\_arn) | ARN of the VPC Lattice service network |
| <a name="output_service_network_auth_policy_arn"></a> [service\_network\_auth\_policy\_arn](#output\_service\_network\_auth\_policy\_arn) | ARN of the service network auth policy |
| <a name="output_service_network_auth_policy_id"></a> [service\_network\_auth\_policy\_id](#output\_service\_network\_auth\_policy\_id) | ID of the service network auth policy |
| <a name="output_service_network_id"></a> [service\_network\_id](#output\_service\_network\_id) | ID of the VPC Lattice service network |
| <a name="output_service_network_name"></a> [service\_network\_name](#output\_service\_network\_name) | Name of the VPC Lattice service network |
| <a name="output_target_group_arns"></a> [target\_group\_arns](#output\_target\_group\_arns) | ARNs of the target groups |
| <a name="output_target_group_attachments"></a> [target\_group\_attachments](#output\_target\_group\_attachments) | Target group attachments |
| <a name="output_target_group_ids"></a> [target\_group\_ids](#output\_target\_group\_ids) | IDs of the target groups |
| <a name="output_vpc_association_ids"></a> [vpc\_association\_ids](#output\_vpc\_association\_ids) | IDs of the VPC associations |
<!-- END_TF_DOCS -->
