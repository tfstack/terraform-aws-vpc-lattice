output "target_group_attachments" {
  description = "Map of target group attachment names to full attachment objects"
  value       = aws_vpclattice_target_group_attachment.this
}

output "attachment_ids" {
  description = "Map of target group attachment names to IDs"
  value = {
    for name, attachment in aws_vpclattice_target_group_attachment.this : name => attachment.id
  }
}
