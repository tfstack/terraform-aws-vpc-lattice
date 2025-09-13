# ECS Fargate with VPC Lattice

A simple example showing VPC Lattice routing traffic to an ECS Fargate service.

## Architecture

```plaintext
┌─────────────────┐    ┌─────────────────┐
│      VPC 1      │    │      VPC 2      │
│   (Client)      │    │   (Backend)     │
│                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │  Jumphost   │ │    │ │ ECS Fargate │ │
│ │   (Test)    │ │    │ │   Service   │ │
│ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────────────────┼───────┐
                                 │       │
                    ┌─────────────────────────────┐
                    │     VPC Lattice Service     │
                    │      Network (IAM Auth)     │
                    │                             │
                    │ ┌─────────────────────────┐ │
                    │ │   ALB Target Group      │ │
                    │ │   (ECS Fargate)         │ │
                    │ └─────────────────────────┘ │
                    └─────────────────────────────┘
```

## Features

- Two VPCs with ECS Fargate service in VPC 2
- VPC Lattice service network with ALB target group
- Auto-scaling ECS service (3-6 tasks)
- Custom domain support

## Usage

### Deploy

```bash
terraform init
terraform plan
terraform apply
```

### Test

SSH to the jumphost and test:

```bash
# Test VPC Lattice service
curl $(terraform output -raw vpc_lattice_service_dns)

# Test custom domain
curl web.example.local
```

Expected response: `<h1>Hello from ECS Fargate!</h1>`

## Configuration

### ECS Service

```hcl
ecs_services = [
  {
    name                 = "hello-webapp"
    desired_count        = 3
    cpu                  = "256"
    memory               = "512"
    container_definitions = jsonencode([
      {
        name      = "hello-webapp"
        image     = "ghcr.io/platformfuzz/go-hello-service:latest"
        cpu       = 256
        memory    = 512
        portMappings = [{
          containerPort = 8000
        }]
      }
    ])
  }
]
```

### VPC Lattice Target Group

```hcl
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
  }
]
```

## Cleanup

```bash
terraform destroy
```
