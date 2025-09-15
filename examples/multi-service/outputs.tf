output "vpc_lattice_service_dns" {
  description = "VPC Lattice service DNS entries"
  value = {
    api      = module.vpc_lattice.service_dns_entries["api"].domain_name
    products = module.vpc_lattice.service_dns_entries["products"].domain_name
  }
}

output "custom_domains" {
  description = "Custom domains for the services"
  value = {
    api      = "api.example.local"
    products = "products.example.local"
  }
}

output "web_server" {
  description = "Web server information"
  value = {
    instance_id   = module.ec2_web_server.instance_id
    private_ip    = module.ec2_web_server.private_ip
    public_ip     = module.ec2_web_server.public_ip
    web_url_http  = "http://${module.ec2_web_server.public_ip}"
    web_url_https = "https://${module.ec2_web_server.public_ip}"
  }
}

output "jumphost" {
  description = "Jumphost information for testing"
  value = {
    instance_id = module.ec2_client.instance_id
    private_ip  = module.ec2_client.private_ip
    public_ip   = module.ec2_client.public_ip
  }
}

output "test_commands" {
  description = "Commands to test the services"
  value = {
    # API Service (Path-based routing)
    api_orders        = "curl -s api.example.local/orders | jq ."
    api_payments      = "curl -s api.example.local/payments | jq ."
    api_inventory     = "curl -s api.example.local/inventory | jq ."
    api_analytics     = "curl -s api.example.local/analytics | jq ."
    api_notifications = "curl -s api.example.local/notifications | jq ."
    api_health        = "curl -s api.example.local/health | jq ."

    # Products Service (Weighted routing)
    products_service = "curl -s products.example.local | jq ."

    # Web Interface
    web_interface = "https://${module.ec2_web_server.public_ip}"
  }
}

output "vpc_lattice_service_arns" {
  description = "VPC Lattice service ARNs"
  value = {
    api      = module.vpc_lattice.service_arns[0]
    products = module.vpc_lattice.service_arns[1]
  }
}

output "target_group_weights" {
  description = "Weight distribution for target groups"
  value = {
    products_v1 = "50%"
    products_v2 = "50%"
  }
}

output "routing_info" {
  description = "Routing configuration information"
  value = {
    api_service = {
      type = "Path-based routing"
      paths = {
        "/orders"        = "Lambda orders service"
        "/payments"      = "Lambda payments service"
        "/inventory"     = "Lambda inventory service"
        "/analytics"     = "ECS Fargate analytics service"
        "/notifications" = "EC2 notifications service"
        "/health"        = "EC2 health service"
        "default"        = "Lambda notfound service"
      }
    }
    products_service = {
      type = "Weighted routing"
      distribution = {
        "products-v1" = "50%"
        "products-v2" = "50%"
      }
    }
  }
}
