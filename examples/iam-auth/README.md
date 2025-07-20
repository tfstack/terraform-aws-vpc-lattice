# VPC Lattice IAM Authentication Example

A simple example showing VPC Lattice with IAM authentication for secure service access.

## Architecture

```plaintext
┌─────────────────┐    ┌─────────────────┐
│      VPC 1      │    │      VPC 2      │
│   (Client)      │    │   (Backend)     │
│                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │  Jumphost   │ │    │ │ ECS Fargate │ │
│ │   (Test)    │ │    │ │   Service   │ │
│ └─────────────┘ │    │ │  Port 8000  │ │
└─────────────────┘    │ └─────────────┘ │
         │             └─────────────────┘
         │                       │
         └───────────────────────┼───────┐
                                 │       │
                    ┌─────────────────────────────┐
                    │     VPC Lattice Service     │
                    │      Network (IAM Auth)     │
                    │                             │
                    │ ┌─────────────────────────┐ │
                    │ │   Web Service (ALB)     │ │
                    │ │   auth_type = "NONE"    │ │
                    │ └─────────────────────────┘ │
                    │ ┌─────────────────────────┐ │
                    │ │   API Service (Lambda)  │ │
                    │ │   auth_type = "AWS_IAM" │ │
                    │ └─────────────────────────┘ │
                    └─────────────────────────────┘
```

## Features

- Two VPCs with ECS Fargate and Lambda services
- VPC Lattice service network with IAM authentication
- Web service (ALB) with network-level auth
- API service (Lambda) with service-level auth
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
# Test web service (no auth required)
curl web.example.local

# Test API service (requires AWS IAM auth)
curl api.example.local
```

Expected responses:

- Web service: `<h1>Hello from ECS Fargate!</h1>`
- API service: `{"message":"Hello from Lambda API!"}`

## Authentication

### Network Level (All Services)

```hcl
auth_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect = "Allow"
      Principal = "*"
      Action = ["vpc-lattice-svcs:Invoke"]
      Resource = "*"
      Condition = {
        StringEquals = {
          "vpc-lattice-svcs:SourceVpc" = [
            module.vpc_1.vpc_id,
            module.vpc_2.vpc_id
          ]
        }
      }
    }
  ]
})
```

### Service Level

- **Web Service**: `auth_type = "NONE"` (inherits network auth)
- **API Service**: `auth_type = "AWS_IAM"` (network + service auth)

## Cleanup

```bash
terraform destroy
```
