output "service_network_id" {
  description = "ID of the VPC Lattice service network"
  value       = var.create_service_network ? aws_vpclattice_service_network.this[0].id : var.service_network_id
}

output "service_network_arn" {
  description = "ARN of the VPC Lattice service network"
  value       = var.create_service_network ? aws_vpclattice_service_network.this[0].arn : null
}

output "service_network_name" {
  description = "Name of the VPC Lattice service network"
  value       = var.service_network.name
}

output "vpc_association_ids" {
  description = "IDs of the VPC associations"
  value       = [for association in aws_vpclattice_service_network_vpc_association.this : association.id]
}

output "service_ids" {
  description = "IDs of the VPC Lattice services"
  value       = [for service in aws_vpclattice_service.this : service.id]
}

output "service_arns" {
  description = "ARNs of the VPC Lattice services"
  value       = [for service in aws_vpclattice_service.this : service.arn]
}

output "service_names" {
  description = "Names of the VPC Lattice services"
  value       = [for service in aws_vpclattice_service.this : service.name]
}

output "target_group_ids" {
  description = "IDs of the target groups"
  value       = values(module.target_groups.target_group_ids)
}

output "target_group_arns" {
  description = "ARNs of the target groups"
  value       = values(module.target_groups.target_group_arns)
}

output "listener_ids" {
  description = "IDs of the listeners"
  value       = values(module.listeners.listener_ids)
}

output "listener_arns" {
  description = "ARNs of the listeners"
  value       = values(module.listeners.listener_arns)
}

output "target_group_attachments" {
  description = "Target group attachments"
  value       = module.target_group_attachments.target_group_attachments
}

output "listener_rules" {
  description = "Listener rules"
  value       = module.listeners.listener_rules
}

output "auth_policy_ids" {
  description = "IDs of the created auth policies"
  value = merge(
    length(module.auth_policies) > 0 ? module.auth_policies[0].auth_policy_ids : {},
    var.create_service_network && var.service_network.auth_policy != null ? {
      service_network = aws_vpclattice_auth_policy.service_network[0].id
    } : {}
  )
}

output "auth_policy_arns" {
  description = "ARNs of the created auth policies"
  value = merge(
    length(module.auth_policies) > 0 ? module.auth_policies[0].auth_policy_arns : {},
    var.create_service_network && var.service_network.auth_policy != null ? {
      service_network = aws_vpclattice_auth_policy.service_network[0].resource_identifier
    } : {}
  )
}

# Service network auth policy outputs
output "service_network_auth_policy_id" {
  description = "ID of the service network auth policy"
  value       = var.create_service_network && var.service_network.auth_policy != null ? aws_vpclattice_auth_policy.service_network[0].id : null
}

output "service_network_auth_policy_arn" {
  description = "ARN of the service network auth policy"
  value       = var.create_service_network && var.service_network.auth_policy != null ? aws_vpclattice_auth_policy.service_network[0].resource_identifier : null
}

# Note: Service network logging is now handled via log_delivery blocks in aws_vpclattice_service_network

output "service_access_log_subscription_ids" {
  description = "IDs of the service access log subscriptions"
  value = {
    for service_name, subscription in aws_vpclattice_access_log_subscription.service : service_name => subscription.id
  }
}

output "service_access_log_subscription_arns" {
  description = "ARNs of the service access log subscriptions"
  value = {
    for service_name, subscription in aws_vpclattice_access_log_subscription.service : service_name => subscription.arn
  }
}

output "per_service_log_group_names" {
  description = "Names of the per-service CloudWatch log groups"
  value = {
    for service_name, log_group in aws_cloudwatch_log_group.service_logs : service_name => log_group.name
  }
}

output "per_service_log_group_arns" {
  description = "ARNs of the per-service CloudWatch log groups"
  value = {
    for service_name, log_group in aws_cloudwatch_log_group.service_logs : service_name => log_group.arn
  }
}

output "service_network_access_log_group_name" {
  description = "Name of the service network access log group"
  value       = var.create_service_network && var.service_network.log_config != null ? aws_cloudwatch_log_group.service_network_access_logs[0].name : null
}

output "service_network_access_log_group_arn" {
  description = "ARN of the service network access log group"
  value       = var.create_service_network && var.service_network.log_config != null ? aws_cloudwatch_log_group.service_network_access_logs[0].arn : null
}

output "service_access_log_group_names" {
  description = "Names of the service access log groups"
  value = {
    for service_name, log_group in aws_cloudwatch_log_group.service_access_logs : service_name => log_group.name
  }
}

output "service_access_log_group_arns" {
  description = "ARNs of the service access log groups"
  value = {
    for service_name, log_group in aws_cloudwatch_log_group.service_access_logs : service_name => log_group.arn
  }
}

output "resource_access_log_group_names" {
  description = "Names of the resource access log groups"
  value = {
    for resource_type, log_group in aws_cloudwatch_log_group.resource_access_logs : resource_type => log_group.name
  }
}

output "resource_access_log_group_arns" {
  description = "ARNs of the resource access log groups"
  value = {
    for resource_type, log_group in aws_cloudwatch_log_group.resource_access_logs : resource_type => log_group.arn
  }
}

output "resource_access_log_subscription_ids" {
  description = "IDs of the resource access log subscriptions"
  value = {
    for resource_type, subscription in aws_vpclattice_access_log_subscription.resource : resource_type => subscription.id
  }
}

output "resource_access_log_subscription_arns" {
  description = "ARNs of the resource access log subscriptions"
  value = {
    for resource_type, subscription in aws_vpclattice_access_log_subscription.resource : resource_type => subscription.arn
  }
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group for VPC Lattice logs"
  value = var.create_log_group ? (
    var.log_group_prevent_destroy ?
    aws_cloudwatch_log_group.lattice_logs_protected[0].arn :
    aws_cloudwatch_log_group.lattice_logs_unprotected[0].arn
  ) : null
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for VPC Lattice logs"
  value = var.create_log_group ? (
    var.log_group_prevent_destroy ?
    aws_cloudwatch_log_group.lattice_logs_protected[0].name :
    aws_cloudwatch_log_group.lattice_logs_unprotected[0].name
  ) : null
}

output "service_dns_entries" {
  description = "DNS entries for the VPC Lattice services"
  value = {
    for service_name, service in aws_vpclattice_service.this : service_name => {
      domain_name    = service.dns_entry[0].domain_name
      hosted_zone_id = service.dns_entry[0].hosted_zone_id
    }
  }
}

output "custom_domain_names" {
  description = "Custom domain names configured for VPC Lattice services"
  value = {
    for service_name, service in aws_vpclattice_service.this : service_name => {
      custom_name        = service.custom_domain_name != null ? split(".", service.custom_domain_name)[0] : null
      custom_domain_name = service.custom_domain_name
      service_dns_name   = service.dns_entry[0].domain_name
    }
  }
}

# Note: IAM policies for VPC Lattice services are managed through AWS IAM
# and attached to the service using the AWS CLI or SDK
# Example: aws vpclattice put-service-policy --service-identifier <service-id> --policy <policy-document>

# Route 53 Outputs
output "route53_zone_id" {
  description = "ID of the Route 53 zone created for custom domains"
  value       = var.create_route53_zone ? aws_route53_zone.custom_domains[0].zone_id : null
}

output "route53_zone_name" {
  description = "Name of the Route 53 zone created for custom domains"
  value       = var.create_route53_zone ? aws_route53_zone.custom_domains[0].name : null
}

output "route53_zone_name_servers" {
  description = "Name servers for the Route 53 zone"
  value       = var.create_route53_zone ? aws_route53_zone.custom_domains[0].name_servers : null
}

output "route53_cname_records" {
  description = "CNAME records created for VPC Lattice services with custom domains"
  value = {
    for service_name, record in aws_route53_record.service_cnames : service_name => {
      name   = record.name
      type   = record.type
      ttl    = record.ttl
      record = tolist(record.records)[0]
    }
  }
}
