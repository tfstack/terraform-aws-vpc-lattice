locals {
  # Flatten target attachments from services with multiple target groups
  target_attachments = flatten([
    for service in var.services : [
      for tg in service.target_groups : [
        for target_index, target in tg.targets : merge(target, {
          target_group_name = tg.name
          target_index      = target_index
        })
      ]
    ]
  ])

  # Flatten listener rules from services
  listener_rules = flatten([
    for service in var.services : [
      for rule in service.listener_rules : merge(rule, {
        service_name      = service.name
        target_group_name = rule.target_group_name != null ? rule.target_group_name : service.target_groups[0].name
      })
    ]
  ])

  # Common tags
  common_tags = merge(var.tags, {
    ManagedBy = "terraform"
    Module    = "vpc-lattice"
  })
}
