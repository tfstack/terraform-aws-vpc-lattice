# VPC Lattice Lambda Example

A simple example showing VPC Lattice with a Lambda function as a service target.

## Architecture

```plaintext
┌─────────────────┐    ┌─────────────────┐
│      VPC 1      │    │      VPC 2      │
│   (Client)      │    │   (Backend)     │
│                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │  Jumphost   │ │    │ │   Lambda    │ │
│ │   (Test)    │ │    │ │  Function   │ │
│ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────────────────┼───────┐
                                 │       │
                    ┌─────────────────────────────┐
                    │     VPC Lattice Service     │
                    │         Network             │
                    │                             │
                    │ ┌─────────────────────────┐ │
                    │ │   Lambda API Service    │ │
                    │ │   auth_type = "NONE"    │ │
                    │ └─────────────────────────┘ │
                    └─────────────────────────────┘
```

## Features

- Two VPCs with Lambda function in VPC 2
- VPC Lattice service network with Lambda target
- Custom domain support
- Simple HTTP API with JSON responses

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
curl http://<vpc-lattice-service-dns>

# Test custom domain
curl http://api.example.local
```

Expected response:

```json
{
  "message": "Hello from VPC Lattice Lambda!",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "event": {
    "version": "2.0",
    "routeKey": "GET /",
    "rawPath": "/"
  }
}
```

## Configuration

### Lambda Function

```hcl
lambda_function = {
  filename      = "lambda_function.zip"
  function_name = "vpc-lattice-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
}
```

### VPC Lattice Service

```hcl
services = [
  {
    name      = "lambda-api"
    protocol  = "HTTP"
    port      = 80
    auth_type = "NONE"

    target_groups = [
      {
        name = "lambda-tg"
        type = "LAMBDA"
        targets = [
          {
            target_id = aws_lambda_function.lambda.arn
          }
        ]
      }
    ]

    default_action = {
      target_group_name = "lambda-tg"
    }
  }
]
```

## Cleanup

```bash
terraform destroy
```
