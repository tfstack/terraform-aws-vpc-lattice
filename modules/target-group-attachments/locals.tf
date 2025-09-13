locals {
  # Flatten target attachments from target groups
  target_attachments = flatten([
    for target_group_name, target_group in var.target_groups : [
      for target_index, target in target_group.targets : merge(target, {
        target_group_name = target_group_name
        target_index      = target_index
      })
    ]
  ])
}
