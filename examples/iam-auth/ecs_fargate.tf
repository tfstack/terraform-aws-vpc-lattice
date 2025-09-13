module "ecs_cluster_fargate" {
  source = "tfstack/ecs-cluster-fargate/aws"

  # Core Configuration
  cluster_name = local.name_2
  suffix       = local.suffix

  # VPC Configuration
  vpc = {
    id = module.vpc_2.vpc_id
    private_subnets = [
      for i, subnet in module.vpc_2.private_subnet_ids :
      { id = subnet, cidr = module.vpc_2.private_subnet_cidrs[i] }
    ]
    public_subnets = [
      for i, subnet in module.vpc_2.public_subnet_ids :
      { id = subnet, cidr = module.vpc_2.public_subnet_cidrs[i] }
    ]
  }

  # Cluster Settings
  cluster_settings = [
    { name = "containerInsights", value = "enabled" }
  ]

  # Logging Configuration
  create_cloudwatch_log_group = true

  # Capacity Providers
  capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  ecs_services = [
    {
      name                 = "hello-webapp"
      desired_count        = 3
      cpu                  = "256"
      memory               = "512"
      force_new_deployment = true

      execution_role_policies = [
        "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
      ]

      container_definitions = jsonencode([
        {
          name      = "hello-webapp"
          image     = "ghcr.io/platformfuzz/go-hello-service:latest"
          cpu       = 256
          memory    = 512
          essential = true
          portMappings = [{
            containerPort = 8000
          }]
          environment = [
            {
              name  = "PORT"
              value = "8000"
            }
          ]
          healthCheck = {
            command = [
              "CMD-SHELL",
              "curl -f http://localhost:8000/health || exit 1"
            ]
            interval    = 30
            timeout     = 5
            retries     = 3
            startPeriod = 60
          }
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = "/aws/ecs/${local.name_2}-hello-webapp"
              awslogs-region        = data.aws_region.current.region
              awslogs-stream-prefix = "${local.name_2}-hello-webapp"
            }
          }
        }
      ])

      deployment_minimum_healthy_percent = 100
      deployment_maximum_percent         = 200
      health_check_grace_period_seconds  = 30

      subnet_ids       = module.vpc_2.private_subnet_ids
      security_groups  = [aws_security_group.fargate_sg.id]
      assign_public_ip = false

      enable_alb              = true
      enable_internal_alb     = true
      enable_ecs_managed_tags = true
      propagate_tags          = "TASK_DEFINITION"

      service_tags = {
        Environment = "dev"
        Project     = "hello-webapp"
        Owner       = "devops"
      }

      task_tags = {
        TaskType = "frontend"
        Version  = "1.0"
      }
    }
  ]

  ecs_autoscaling = [
    {
      service_name           = "${local.name_2}-hello-webapp"
      min_capacity           = 3
      max_capacity           = 6
      scalable_dimension     = "ecs:service:DesiredCount"
      policy_name            = "scale-on-cpu"
      policy_type            = "TargetTrackingScaling"
      target_value           = 80
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  ]

  tags = local.tags_1
}
