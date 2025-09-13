output "vpc_lattice_service_dns" {
  description = "VPC Lattice service DNS entry"
  value       = module.vpc_lattice.service_dns_entries["api"].domain_name
}

output "custom_domain" {
  description = "Custom domain for the e-commerce API service"
  value       = "api.ecommerce.local"
}

output "test_commands" {
  description = "Commands to test the e-commerce microservices"
  value = {
    products  = "curl api.ecommerce.local/products"
    orders    = "curl api.ecommerce.local/orders"
    payments  = "curl api.ecommerce.local/payments"
    inventory = "curl api.ecommerce.local/inventory"
    analytics = "curl api.ecommerce.local/analytics"
    notfound  = "curl api.ecommerce.local/unknown"
  }
}
