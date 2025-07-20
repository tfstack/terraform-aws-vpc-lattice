# Target Group Attachments
resource "aws_vpclattice_target_group_attachment" "this" {
  for_each = {
    for target in local.target_attachments : "${target.target_group_name}-${tostring(target.target_index)}" => target
  }

  target_group_identifier = var.target_group_ids[each.value.target_group_name]

  target {
    id   = each.value.target_id
    port = try(each.value.port, null)
  }

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    create = "5m"
    delete = "30m"
  }
}
