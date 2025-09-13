############################################
# VPC Lattice Auth Policies
############################################

locals {
  # Services that have custom auth policies defined
  services_with_custom_policies = {
    for service_name, service_config in var.services : service_name => service_config
    if lookup(service_config, "auth_policy", null) != null
  }

  # Services that need default policies (AWS_IAM auth_type WITHOUT custom policies)
  services_needing_default_policies = {
    for service_name, service_config in var.services : service_name => service_config
    if lookup(service_config, "auth_policy", null) == null && lookup(service_config, "auth_type", "NONE") == "AWS_IAM"
  }

  # Debug: Show which services fall into which category
  debug_info = {
    custom_policy_services  = keys(local.services_with_custom_policies)
    default_policy_services = keys(local.services_needing_default_policies)
    all_services            = keys(var.services)
  }
}

# Create custom auth policies for services that specify them
resource "aws_vpclattice_auth_policy" "custom_policies" {
  for_each = local.services_with_custom_policies

  resource_identifier = var.service_arns[each.key]
  policy              = each.value.auth_policy
}

# Create default auth policies for AWS_IAM services WITHOUT custom policies
resource "aws_vpclattice_auth_policy" "default_policies" {
  for_each = local.services_needing_default_policies

  resource_identifier = var.service_arns[each.key]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "vpc-lattice-svcs:Invoke"
        ]
        Resource = "*"
      }
    ]
  })
}
