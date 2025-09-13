output "service_dns_entries" {
  description = "VPC Lattice service DNS entries"
  value = {
    web = module.vpc_lattice.service_dns_entries["web"].domain_name
    api = module.vpc_lattice.service_dns_entries["api"].domain_name
  }
}

output "custom_domains" {
  description = "Custom domains for the services"
  value = {
    web = "web.example.local"
    api = "api.example.local"
  }
}

output "test_commands" {
  description = "Commands to test the IAM auth services"
  value = {
    web_vpc_lattice   = "curl ${module.vpc_lattice.service_dns_entries["web"].domain_name}"
    web_custom_domain = "curl web.example.local"
    api_vpc_lattice   = "curl ${module.vpc_lattice.service_dns_entries["api"].domain_name}"
    api_custom_domain = "curl api.example.local"
  }
}

output "vpc_lattice_service_arn" {
  description = "VPC Lattice service ARN"
  value       = module.vpc_lattice.service_arns[0]
}
