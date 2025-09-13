
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
      Purpose     = "weighted-routing"
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
        VPCType = "ec2-web"
      }
    },
    {
      vpc_id = module.vpc_3.vpc_id
      security_group_ids = [
        aws_security_group.vpc_lattice_3_sg.id
      ]
      tags = {
        VPCType = "alb-web"
      }
    }
  ]

  # Enable automatic Route 53 zone creation for custom domains
  create_route53_zone = true
  route53_zone_name   = "example.local"
  route53_vpc_ids = [
    module.vpc_1.vpc_id,
    module.vpc_2.vpc_id,
    module.vpc_3.vpc_id
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

      # Multiple target groups for weighted routing
      target_groups = [
        {
          name     = "ec2-web-server-1"
          type     = "INSTANCE"
          protocol = "HTTP"
          port     = 80
          vpc_id   = module.vpc_2.vpc_id
          weight   = 25
          targets = [
            {
              target_id = module.ec2_web_server_1.instance_id
              port      = 80
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
            TargetGroup = "ec2-web-server-1"
            Weight      = "25"
            Purpose     = "ec2-web-server"
          }
        },
        {
          name     = "ec2-web-server-2"
          type     = "INSTANCE"
          protocol = "HTTP"
          port     = 80
          vpc_id   = module.vpc_2.vpc_id
          weight   = 25
          targets = [
            {
              target_id = module.ec2_web_server_2.instance_id
              port      = 80
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
            TargetGroup = "ec2-web-server-2"
            Weight      = "25"
            Purpose     = "ec2-web-server"
          }
        },
        {
          name     = "alb-web-server-1"
          type     = "ALB"
          protocol = "HTTP"
          port     = 80
          vpc_id   = module.vpc_3.vpc_id
          weight   = 25
          targets = [
            {
              target_id = module.alb.alb_arn
              port      = 80
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
            Weight      = "25"
            Purpose     = "alb-web-server-1"
          }
        },
        {
          name                           = "lambda-api-1"
          type                           = "LAMBDA"
          weight                         = 25
          lambda_event_structure_version = "V1"
          targets = [
            {
              target_id = aws_lambda_function.api_handler.arn
            }
          ]
          tags = merge(local.tags_1, {
            TargetGroup = "lambda-api-1"
            Weight      = "25"
            Purpose     = "lambda-api-1"
          })
        }
      ]

      tags = {
        Service     = "web"
        RoutingType = "weighted"
      }
    }
  ]

  create_log_group          = true
  log_group_name            = "/aws/vpclattice/cltest"
  log_retention_days        = 1
  log_group_prevent_destroy = false

  tags = {
    Module  = "vpc-lattice"
    Example = "weighted-routing"
  }
}
