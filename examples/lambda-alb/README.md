# VPC Lattice Lambda ALB Example

A simple example showing VPC Lattice with Lambda functions behind an Application Load Balancer.

## Architecture

```plaintext
┌─────────────────┐    ┌─────────────────┐
│      VPC 1      │    │      VPC 2      │
│   (Client)      │    │   (Backend)     │
│                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │  Jumphost   │ │    │ │     ALB     │ │
│ │   (Test)    │ │    │ │   (Internal)│ │
│ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    │ ┌─────────────┐ │
         │             │ │   Lambda    │ │
         │             │ │  Function   │ │
         │             │ └─────────────┘ │
         │             └─────────────────┘
         │                       │
         └───────────────────────┼───────┐
                                 │       │
                    ┌─────────────────────────────┐
                    │     VPC Lattice Service     │
                    │      Network (IAM Auth)     │
                    │                             │
                    │ ┌─────────────────────────┐ │
                    │ │   Order API Service     │ │
                    │ │   (ALB + Lambda)        │ │
                    │ └─────────────────────────┘ │
                    └─────────────────────────────┘
```

## Features

- Two VPCs with Lambda function behind ALB in VPC 2
- VPC Lattice service network with IAM authentication
- Internal ALB with Lambda target
- Custom domain support
- Health checks and logging

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
curl order-api.example.local
```

Expected response:

```json
{
  "message": "Hello from Order API!",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "service": "order-api"
}
```

## Configuration

### VPC Lattice Service

```hcl
services = [
  {
    name      = "order-api"
    protocol  = "HTTP"
    port      = 80
    auth_type = "AWS_IAM"

    target_groups = [
      {
        name     = "lambda-order-api-tg"
        type     = "ALB"
        protocol = "HTTP"
        port     = 80
        vpc_id   = module.vpc_2.vpc_id
        targets = [
          {
            target_id = module.alb_order_api.alb_arn
            port      = 80
          }
        ]
      }
    ]
  }
]
```

### ALB Configuration

```hcl
module "alb_order_api" {
  source = "tfstack/alb/aws"

  name               = "order-api"
  vpc_id             = module.vpc_2.vpc_id
  private_subnet_ids = module.vpc_2.private_subnet_ids
  internal           = true
  targets            = [module.lambda_order_api.arn]
  target_type        = "lambda"
}
```

## Cleanup

```bash
terraform destroy
```
