output "listener_ids" {
  description = "Map of listener names to IDs"
  value = {
    for name, listener in aws_vpclattice_listener.this : name => listener.id
  }
}

output "listener_arns" {
  description = "Map of listener names to ARNs"
  value = {
    for name, listener in aws_vpclattice_listener.this : name => listener.arn
  }
}

output "listener_rules" {
  description = "Map of listener rule names to full rule objects"
  value       = aws_vpclattice_listener_rule.this
}
