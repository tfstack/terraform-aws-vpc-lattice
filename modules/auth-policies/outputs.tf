############################################
# Outputs
############################################

output "auth_policy_ids" {
  description = "IDs of the created auth policies (both custom and default)"
  value = merge(
    {
      for service_name, policy in aws_vpclattice_auth_policy.custom_policies : service_name => policy.id
    },
    {
      for service_name, policy in aws_vpclattice_auth_policy.default_policies : service_name => policy.id
    }
  )
}

output "auth_policy_arns" {
  description = "ARNs of the created auth policies (both custom and default)"
  value = merge(
    {
      for service_name, policy in aws_vpclattice_auth_policy.custom_policies : service_name => policy.resource_identifier
    },
    {
      for service_name, policy in aws_vpclattice_auth_policy.default_policies : service_name => policy.resource_identifier
    }
  )
}

# Debug outputs to help troubleshoot
output "debug_services_with_custom_policies" {
  description = "Services that have custom auth policies"
  value       = local.services_with_custom_policies
}

output "debug_services_needing_default_policies" {
  description = "Services that need default auth policies (AWS_IAM without custom)"
  value       = local.services_needing_default_policies
}

output "debug_all_services" {
  description = "All services passed to the module"
  value       = var.services
}

output "debug_info" {
  description = "Debug information about service categorization"
  value       = local.debug_info
}
