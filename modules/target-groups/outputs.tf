output "target_group_ids" {
  description = "Map of target group names to IDs"
  value = {
    for name, target_group in aws_vpclattice_target_group.this : name => target_group.id
  }
}

output "target_group_arns" {
  description = "Map of target group names to ARNs"
  value = {
    for name, target_group in aws_vpclattice_target_group.this : name => target_group.arn
  }
}
