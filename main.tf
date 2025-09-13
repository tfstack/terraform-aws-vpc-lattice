# VPC Lattice Service Network
resource "aws_vpclattice_service_network" "this" {
  count = var.create_service_network ? 1 : 0

  name      = var.service_network.name
  auth_type = var.service_network.auth_type


  tags = merge(
    var.service_network.tags,
    {
      Name = var.service_network.name
    }
  )
}

# Service Network Auth Policy (if specified)
resource "aws_vpclattice_auth_policy" "service_network" {
  count = var.create_service_network && var.service_network.auth_policy != null ? 1 : 0

  resource_identifier = aws_vpclattice_service_network.this[0].arn
  policy              = var.service_network.auth_policy
}

# Service Network Access Log Subscription (if specified)
resource "aws_vpclattice_access_log_subscription" "service_network" {
  count = var.create_service_network && var.service_network.log_config != null ? 1 : 0

  resource_identifier = aws_vpclattice_service_network.this[0].arn
  destination_arn     = var.service_network.log_config.destination_arn != null ? var.service_network.log_config.destination_arn : aws_cloudwatch_log_group.service_network_access_logs[0].arn

  tags = merge(
    var.service_network.tags,
    {
      Name = "${var.service_network.name}-access-logs"
    }
  )

  depends_on = [aws_cloudwatch_log_group.service_network_access_logs]
}

# Note: Service network resource access logs conflict with service access logs
# Resource access logs are only available for individual services

# VPC Associations
resource "aws_vpclattice_service_network_vpc_association" "this" {
  for_each = { for idx, vpc in var.vpc_associations : idx => vpc }

  service_network_identifier = var.create_service_network ? aws_vpclattice_service_network.this[0].id : var.service_network_id
  vpc_identifier             = each.value.vpc_id
  security_group_ids         = each.value.security_group_ids

  tags = merge(
    each.value.tags,
    {
      Name = "${var.service_network.name}-vpc-association-${each.key}"
    }
  )

  lifecycle {
    ignore_changes = [vpc_identifier]
  }

  timeouts {
    delete = "30m"
  }
}

# Local variables for target group processing
locals {
  # Flatten target groups from all services
  all_target_groups = merge([
    for service in var.services : {
      for tg in service.target_groups : tg.name => tg
    }
  ]...)
}

# Target Groups and Attachments - Using submodule for better dependency management
module "target_groups" {
  source = "./modules/target-groups"

  target_groups = local.all_target_groups

  tags = var.tags
}

# Target Group Attachments - Separate module for better lifecycle management
module "target_group_attachments" {
  source = "./modules/target-group-attachments"

  target_groups = local.all_target_groups

  target_group_ids = module.target_groups.target_group_ids

  depends_on = [module.target_groups]
}

# Lattice Services - Use service names as keys instead of array indices
resource "aws_vpclattice_service" "this" {
  for_each = { for service in var.services : service.name => service }

  name      = each.value.name
  auth_type = each.value.auth_type

  custom_domain_name = each.value.custom_name != null && each.value.custom_name != "" && var.route53_zone_name != null ? "${each.value.custom_name}.${var.route53_zone_name}" : null

  tags = merge(
    each.value.tags,
    {
      Name = each.value.name
    }
  )

  timeouts {
    delete = "30m"
  }
}

# Service Access Log Subscriptions (if specified)
resource "aws_vpclattice_access_log_subscription" "service" {
  for_each = {
    for service in var.services : service.name => service
    if service.log_config != null
  }

  resource_identifier = aws_vpclattice_service.this[each.key].arn
  destination_arn     = each.value.log_config.destination_arn != null ? each.value.log_config.destination_arn : aws_cloudwatch_log_group.service_access_logs[each.key].arn

  tags = merge(
    each.value.tags,
    {
      Name = "${each.key}-access-logs"
    }
  )

  depends_on = [aws_cloudwatch_log_group.service_access_logs]
}

# Resource Access Log Subscriptions (if enabled)
# Note: We create resource access logs for services that don't have service access logs
# to avoid conflicts with existing access log subscriptions
resource "aws_vpclattice_access_log_subscription" "resource" {
  for_each = var.enable_resource_access_logs ? {
    for service in var.services : service.name => service
    if service.log_config == null # Only for services without service access logs
  } : {}

  resource_identifier = aws_vpclattice_service.this[each.key].arn
  destination_arn     = aws_cloudwatch_log_group.resource_access_logs["services"].arn

  tags = merge(
    each.value.tags,
    var.tags,
    {
      Name    = "${each.key}-resource-access-logs"
      Purpose = "resource-access-logs"
      Type    = "service"
    }
  )

  depends_on = [aws_cloudwatch_log_group.resource_access_logs]
}

# Service Network Service Associations - Use service names as keys
resource "aws_vpclattice_service_network_service_association" "this" {
  for_each = { for service in var.services : service.name => service }

  service_network_identifier = var.create_service_network ? aws_vpclattice_service_network.this[0].id : var.service_network_id
  service_identifier         = aws_vpclattice_service.this[each.key].id

  tags = merge(
    each.value.tags,
    {
      Name = "${each.value.name}-service-association"
    }
  )

  timeouts {
    delete = "30m"
  }
}

# Listeners and Listener Rules - Using submodule for better dependency management
module "listeners" {
  source = "./modules/listeners"

  listeners = {
    for service in var.services : service.name => {
      name               = service.name
      protocol           = service.protocol
      port               = service.port
      service_identifier = aws_vpclattice_service.this[service.name].id
      target_groups = [
        for tg in service.target_groups : {
          target_group_identifier = module.target_groups.target_group_ids[tg.name]
          weight                  = tg.weight
        }
      ]
      default_action = service.default_action != null ? {
        target_group_identifier = module.target_groups.target_group_ids[service.default_action.target_group_name]
        weight                  = service.default_action.weight
      } : null
      tags = service.tags
    }
  }

  listener_rules = [
    for rule in local.listener_rules : merge(rule, {
      target_group_identifier = module.target_groups.target_group_ids[rule.target_group_name]
      service_identifier      = aws_vpclattice_service.this[rule.service_name].id
    })
  ]

  tags = var.tags

  depends_on = [
    module.target_groups,
    module.target_group_attachments
  ]
}

# Auth Policies - Using submodule for better organization
module "auth_policies" {
  source = "./modules/auth-policies"
  count  = length([for service in var.services : service if service.auth_type == "AWS_IAM"]) > 0 ? 1 : 0

  services = {
    for service in var.services : service.name => service
  }
  service_arns = {
    for service_name, service in aws_vpclattice_service.this : service_name => service.arn
  }
  tags = var.tags

  depends_on = [
    aws_vpclattice_service.this,
    aws_vpclattice_service_network_service_association.this
  ]
}

# CloudWatch Log Groups for Logging
# CloudWatch Log Group - Protected (prevent_destroy = true)
resource "aws_cloudwatch_log_group" "lattice_logs_protected" {
  count = var.create_log_group && var.log_group_prevent_destroy ? 1 : 0

  name              = var.log_group_name
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name = var.log_group_name
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

# Per-Service CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "service_logs" {
  for_each = var.create_per_service_log_groups ? { for service in var.services : service.name => service } : {}

  name              = var.service_log_group_name_prefix != null ? "${var.service_log_group_name_prefix}/${each.key}" : "${var.log_group_name_prefix}/services/${each.key}"
  retention_in_days = var.log_retention_days

  tags = merge(
    each.value.tags,
    var.tags,
    {
      Name    = var.service_log_group_name_prefix != null ? "${var.service_log_group_name_prefix}/${each.key}" : "${var.log_group_name_prefix}/services/${each.key}"
      Service = each.key
      Purpose = "per-service-logs"
    }
  )
}

# Service Network Access Log Group (if log_config is specified)
resource "aws_cloudwatch_log_group" "service_network_access_logs" {
  count = var.create_service_network && var.service_network.log_config != null ? 1 : 0

  name              = var.service_network_log_group_name != null ? var.service_network_log_group_name : "${var.log_group_name_prefix}/${var.service_network.name}-access-logs"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.service_network.tags,
    var.tags,
    {
      Name    = var.service_network_log_group_name != null ? var.service_network_log_group_name : "${var.log_group_name_prefix}/${var.service_network.name}-access-logs"
      Purpose = "service-network-access-logs"
    }
  )
}

# Service Access Log Groups (if log_config is specified for services)
resource "aws_cloudwatch_log_group" "service_access_logs" {
  for_each = {
    for service in var.services : service.name => service
    if service.log_config != null
  }

  name              = var.service_log_group_name_prefix != null ? "${var.service_log_group_name_prefix}/${each.key}-access-logs" : "${var.log_group_name_prefix}/services/${each.key}-access-logs"
  retention_in_days = var.log_retention_days

  tags = merge(
    each.value.tags,
    var.tags,
    {
      Name    = var.service_log_group_name_prefix != null ? "${var.service_log_group_name_prefix}/${each.key}-access-logs" : "${var.log_group_name_prefix}/services/${each.key}-access-logs"
      Service = each.key
      Purpose = "service-access-logs"
    }
  )
}

# Resource Access Log Groups (if resource access logs are enabled)
resource "aws_cloudwatch_log_group" "resource_access_logs" {
  for_each = var.enable_resource_access_logs ? {
    services = "services"
  } : {}

  name              = var.resource_log_group_name_prefix != null ? "${var.resource_log_group_name_prefix}/${each.key}-access-logs" : "${var.log_group_name_prefix}/resources/${each.key}-access-logs"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name    = var.resource_log_group_name_prefix != null ? "${var.resource_log_group_name_prefix}/${each.key}-access-logs" : "${var.log_group_name_prefix}/resources/${each.key}-access-logs"
      Purpose = "resource-access-logs"
    }
  )
}

# CloudWatch Log Group - Unprotected (prevent_destroy = false)
resource "aws_cloudwatch_log_group" "lattice_logs_unprotected" {
  count = var.create_log_group && !var.log_group_prevent_destroy ? 1 : 0

  name              = var.log_group_name
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name = var.log_group_name
    }
  )

  lifecycle {
    prevent_destroy = false
  }
}

# Route 53 Zone for Custom Domains
resource "aws_route53_zone" "custom_domains" {
  count = var.create_route53_zone ? 1 : 0

  name = var.route53_zone_name

  dynamic "vpc" {
    for_each = var.route53_vpc_ids
    content {
      vpc_id = vpc.value
    }
  }

  tags = merge(
    var.route53_zone_tags,
    var.tags,
    {
      Name = var.route53_zone_name
    }
  )
}

# Route 53 CNAME Records for Services with Custom Domains
resource "aws_route53_record" "service_cnames" {
  for_each = {
    for service_name, service in aws_vpclattice_service.this : service_name => service
    if var.create_route53_zone && service.custom_domain_name != null && service.custom_domain_name != ""
  }

  zone_id = aws_route53_zone.custom_domains[0].zone_id
  name    = each.value.custom_domain_name
  type    = "CNAME"
  ttl     = "300"
  records = [each.value.dns_entry[0].domain_name]

  depends_on = [aws_vpclattice_service.this]
}
