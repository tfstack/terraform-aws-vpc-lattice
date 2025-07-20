output "vpc_lattice_service_dns" {
  description = "VPC Lattice service DNS entry"
  value       = module.vpc_lattice.service_dns_entries["order-api"].domain_name
}

output "custom_domain" {
  description = "Custom domain for the api service"
  value       = "order-api.example.local"
}

output "test_commands" {
  description = "Commands to test the weighted routing service"
  value = {
    vpc_lattice   = "curl -s ${module.vpc_lattice.service_dns_entries["order-api"].domain_name} | jq ."
    custom_domain = "curl -s order-api.example.local | jq ."
  }
}

output "vpc_lattice_service_arn" {
  description = "VPC Lattice service ARN"
  value       = module.vpc_lattice.service_arns[0]
}
