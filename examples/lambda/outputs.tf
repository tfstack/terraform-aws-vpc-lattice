output "service_dns_entries" {
  description = "VPC Lattice service DNS entries"
  value = {
    api = module.vpc_lattice.service_dns_entries["api"].domain_name
  }
}

output "custom_domains" {
  description = "Custom domains for the services"
  value = {
    api = "api.example.local"
  }
}

output "test_commands" {
  description = "Commands to test the Lambda API service"
  value = {
    api_vpc_lattice   = "curl ${module.vpc_lattice.service_dns_entries["api"].domain_name}"
    api_custom_domain = "curl api.example.local"
  }
}

output "vpc_lattice_service_arn" {
  description = "VPC Lattice service ARN"
  value       = module.vpc_lattice.service_arns[0]
}
