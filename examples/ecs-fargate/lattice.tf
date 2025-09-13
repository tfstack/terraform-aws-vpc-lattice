
############################################
# VPC Lattice Configuration
############################################

module "vpc_lattice" {
  source = "../../"

  create_service_network = true
  service_network = {
    name      = "cltest-network"
    auth_type = "NONE"
    tags = {
      Name        = "cltest-network"
      NetworkType = "service-network"
    }
  }

  vpc_associations = [
    {
      vpc_id = module.vpc_1.vpc_id
      security_group_ids = [
        aws_security_group.vpc_lattice_1_sg.id
      ]
      tags = {
        VPCType = "client"
      }
    },
    {
      vpc_id = module.vpc_2.vpc_id
      security_group_ids = [
        aws_security_group.vpc_lattice_2_sg.id
      ]
      tags = {
        VPCType = "ecs-fargate-web"
      }
    }
  ]

  # Enable automatic Route 53 zone creation for custom domains
  create_route53_zone = true
  route53_zone_name   = "example.local"
  route53_vpc_ids = [
    module.vpc_1.vpc_id,
    module.vpc_2.vpc_id
  ]
  route53_zone_tags = {
    DNSZone = "custom-domain"
    Purpose = "service-discovery"
  }

  services = [
    {
      name      = "web"
      protocol  = "HTTP"
      port      = 80
      auth_type = "NONE"

      custom_name = "web"

      target_groups = [
        {
          name     = "alb-web-server-1"
          type     = "ALB"
          protocol = "HTTP"
          port     = 8000
          vpc_id   = module.vpc_2.vpc_id
          targets = [
            {
              target_id = module.ecs_cluster_fargate.alb_arns["hello-webapp"]
              port      = 8000
            }
          ]
          health_check = {
            path                = "/"
            interval            = 10
            timeout             = 5
            healthy_threshold   = 1
            unhealthy_threshold = 2
          }
          tags = {
            TargetGroup = "alb-web-server-1"
          }
        }
      ]

      tags = {
        Service     = "web"
        RoutingType = "basic"
      }
    }
  ]

  create_log_group          = true
  log_group_name            = "/aws/vpclattice/cltest-network"
  log_retention_days        = 1
  log_group_prevent_destroy = false

  tags = {
    Module  = "vpc-lattice"
    Example = "basic"
  }
}
