module "ecs_cluster_fargate" {
  source = "tfstack/ecs-cluster-fargate/aws"

  # Core Configuration
  cluster_name = local.name_3
  suffix       = local.suffix

  # VPC Configuration
  vpc = {
    id = module.vpc_3.vpc_id
    private_subnets = [
      for i, subnet in module.vpc_3.private_subnet_ids :
      { id = subnet, cidr = module.vpc_3.private_subnet_cidrs[i] }
    ]
    public_subnets = [
      for i, subnet in module.vpc_3.public_subnet_ids :
      { id = subnet, cidr = module.vpc_3.public_subnet_cidrs[i] }
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
      name                 = "analytics-service"
      desired_count        = 2
      cpu                  = "512"
      memory               = "1024"
      force_new_deployment = true

      execution_role_policies = [
        "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
      ]

      container_definitions = jsonencode([
        {
          name      = "analytics-service"
          image     = "nginx:alpine"
          cpu       = 512
          memory    = 1024
          essential = true

          portMappings = [{
            containerPort = 8000
          }]

          environment = [
            { name = "SERVICE_NAME", value = "analytics-service" },
            { name = "SERVICE_VERSION", value = "2.0" },
            { name = "TARGET_TYPE", value = "ECS_FARGATE" }
          ]

          command = [
            "sh", "-c", <<-EOT
        mkdir -p /usr/share/nginx/html
        cat > /usr/share/nginx/html/index.json << 'EOF'
{
  "api_version": "2.0",
  "service": "analytics-service",
  "message": "Advanced Analytics Service V2 (Container)",
  "target_type": "ECS_FARGATE",
  "analytics_data": {
    "total_requests": 7500,
    "active_users": 650,
    "response_time_ms": 85,
    "error_rate": "1.2",
    "throughput_rps": 95
  },
  "metrics": {
    "cpu_usage": "35.5%",
    "memory_usage": "45.2%",
    "container_count": 2,
    "uptime_hours": 12
  },
  "features": [
    "Real-time Analytics",
    "Container Orchestration",
    "Auto-scaling",
    "Health Monitoring",
    "Advanced Metrics"
  ],
  "timestamp": "2024-01-15T10:30:00Z",
  "version_info": {
    "container_version": "2.0",
    "deployment_date": "2024-01-15",
    "orchestration": "ECS Fargate",
    "features": ["Container-based", "Auto-scaling", "Health Checks", "CloudWatch Logs"]
  }
}
EOF
        cat > /usr/share/nginx/html/health << 'EOF'
{"status": "healthy", "service": "analytics-service"}
EOF
        cat > /etc/nginx/conf.d/default.conf << 'EOF'
server {
    listen 8000;
    location / {
        add_header Content-Type application/json;
        return 200 '{"api_version":"2.0","service":"analytics-service","message":"Advanced Analytics Service V2 (Container)","target_type":"ECS_FARGATE","analytics_data":{"total_requests":7500,"active_users":650,"response_time_ms":85,"error_rate":"1.2","throughput_rps":95},"metrics":{"cpu_usage":"35.5%","memory_usage":"45.2%","container_count":2,"uptime_hours":12},"features":["Real-time Analytics","Container Orchestration","Auto-scaling","Health Monitoring","Advanced Metrics"],"timestamp":"2024-01-15T10:30:00Z","version_info":{"container_version":"2.0","deployment_date":"2024-01-15","orchestration":"ECS Fargate","features":["Container-based","Auto-scaling","Health Checks","CloudWatch Logs"]}}';
    }
    location /health {
        add_header Content-Type application/json;
        return 200 '{"status":"healthy","service":"analytics-service"}';
    }
}
EOF
        nginx -g 'daemon off;'
      EOT
          ]

          healthCheck = {
            command = [
              "CMD-SHELL",
              "wget --no-verbose --tries=1 --spider http://localhost:8000/health || exit 1"
            ]
            interval    = 30
            timeout     = 5
            retries     = 3
            startPeriod = 120
          }

          logConfiguration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = "/aws/ecs/${local.name_3}-analytics-service"
              awslogs-region        = data.aws_region.current.region
              awslogs-stream-prefix = "${local.name_3}-analytics-service"
            }
          }
        }
      ])

      deployment_minimum_healthy_percent = 100
      deployment_maximum_percent         = 200
      health_check_grace_period_seconds  = 30

      subnet_ids       = module.vpc_3.private_subnet_ids
      security_groups  = [aws_security_group.fargate_sg.id]
      assign_public_ip = false

      enable_alb              = true
      enable_internal_alb     = true
      enable_ecs_managed_tags = true
      propagate_tags          = "TASK_DEFINITION"

      service_tags = {
        Environment = "dev"
        Project     = "analytics-service"
        Owner       = "devops"
        Service     = "analytics"
        TargetType  = "ECS_FARGATE"
      }

      task_tags = {
        TaskType   = "analytics"
        Version    = "2.0"
        TargetType = "container"
      }
    }
  ]

  ecs_autoscaling = [
    {
      service_name           = "${local.name_3}-analytics-service"
      min_capacity           = 2
      max_capacity           = 4
      scalable_dimension     = "ecs:service:DesiredCount"
      policy_name            = "scale-on-cpu"
      policy_type            = "TargetTrackingScaling"
      target_value           = 70
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  ]

  tags = local.tags_3
}
