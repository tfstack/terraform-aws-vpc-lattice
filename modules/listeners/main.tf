# Listeners
resource "aws_vpclattice_listener" "this" {
  for_each = var.listeners

  name               = "${each.value.name}-listener"
  protocol           = each.value.protocol
  port               = each.value.port
  service_identifier = each.value.service_identifier

  default_action {
    forward {
      dynamic "target_groups" {
        for_each = each.value.default_action != null ? [each.value.default_action] : each.value.target_groups
        content {
          target_group_identifier = each.value.default_action != null ? each.value.default_action.target_group_identifier : target_groups.value.target_group_identifier
          weight                  = each.value.default_action != null ? each.value.default_action.weight : target_groups.value.weight
        }
      }
    }
  }

  tags = merge(
    each.value.tags,
    {
      Name = "${each.value.name}-listener"
    }
  )

  timeouts {
    delete = "30m"
  }
}

# Listener Rules
resource "aws_vpclattice_listener_rule" "this" {
  for_each = {
    for rule in local.listener_rules : "${rule.service_name}-${rule.priority}" => rule
  }

  listener_identifier = aws_vpclattice_listener.this[each.value.service_name].arn
  service_identifier  = each.value.service_identifier
  name                = "${each.value.service_name}-rule-${each.value.priority}"
  priority            = each.value.priority

  dynamic "match" {
    for_each = each.value.match != null ? [each.value.match] : []
    content {
      dynamic "http_match" {
        for_each = match.value.http_match != null ? [match.value.http_match] : []
        content {
          dynamic "header_matches" {
            for_each = http_match.value.header_name != null && http_match.value.header_value != null ? [1] : []
            content {
              name = http_match.value.header_name
              match {
                exact = http_match.value.header_value
              }
            }
          }
          method = try(http_match.value.method, null)
          path_match {
            match {
              exact  = http_match.value.path_match_type == "exact" ? http_match.value.path : null
              prefix = http_match.value.path_match_type == "prefix" ? http_match.value.path : null
            }
          }
        }
      }
    }
  }

  dynamic "action" {
    for_each = each.value.action != null ? [each.value.action] : []
    content {
      forward {
        target_groups {
          target_group_identifier = each.value.target_group_identifier
          weight                  = try(action.value.weight, 1)
        }
      }
    }
  }

  tags = merge(
    each.value.tags,
    {
      Name = "${each.value.service_name}-rule-${each.value.priority}"
    }
  )

  timeouts {
    delete = "30m"
  }
}
