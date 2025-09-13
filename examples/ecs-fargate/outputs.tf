output "vpc_lattice_service_dns" {
  description = "VPC Lattice service DNS entry"
  value       = module.vpc_lattice.service_dns_entries["web"].domain_name
}

output "custom_domain" {
  description = "Custom domain for the web service"
  value       = "web.example.local"
}

output "test_commands" {
  description = "Commands to test the weighted routing service"
  value = {
    vpc_lattice   = "curl ${module.vpc_lattice.service_dns_entries["web"].domain_name}"
    custom_domain = "curl web.example.local"
  }
}

output "vpc_lattice_service_arn" {
  description = "VPC Lattice service ARN"
  value       = module.vpc_lattice.service_arns[0]
}
