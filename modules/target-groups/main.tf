# Target Groups
resource "aws_vpclattice_target_group" "this" {
  for_each = var.target_groups

  name = each.value.name
  type = each.value.type

  dynamic "config" {
    for_each = each.value.type == "LAMBDA" ? [each.value] : []
    content {
      lambda_event_structure_version = try(config.value.lambda_event_structure_version, "V1")
    }
  }

  dynamic "config" {
    for_each = each.value.type == "ALB" ? [each.value] : []
    content {
      port           = config.value.port
      protocol       = config.value.protocol
      vpc_identifier = config.value.vpc_id
    }
  }

  dynamic "config" {
    for_each = each.value.type == "INSTANCE" ? [each.value] : []
    content {
      port           = config.value.port
      protocol       = config.value.protocol
      vpc_identifier = config.value.vpc_id
    }
  }

  dynamic "config" {
    for_each = each.value.type == "IP" ? [each.value] : []
    content {
      port           = config.value.port
      protocol       = config.value.protocol
      vpc_identifier = config.value.vpc_id
    }
  }

  tags = merge(
    each.value.tags,
    {
      Name = each.value.name
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
