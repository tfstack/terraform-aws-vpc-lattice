# VPC Lattice Multi-Service Example

A comprehensive example showing VPC Lattice with multiple services across different target types and routing patterns.

## Architecture

```plaintext
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      VPC 1      │    │      VPC 2      │    │      VPC 3      │
│   (Client)      │    │   (Backend)     │    │   (Backend)     │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │  Jumphost   │ │    │ │   Lambda    │ │    │ │ ECS Fargate │ │
│ │   (Test)    │ │    │ │  Functions  │ │    │ │   Service   │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ Web Server  │ │    │ │     ALB     │ │    │ │ Notifications│ │
│ │ (Interface) │ │    │ └─────────────┘ │    │ │   Service   │ │
│ └─────────────┘ │    └─────────────────┘    │ │    (EC2)    │ │
└─────────────────┘                          │ └─────────────┘ │
         │                                   │ ┌─────────────┐ │
         │                                   │ │     ALB     │ │
         │                                   │ └─────────────┘ │
         │                                   └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┼───────┐
                                 │                       │       │
                    ┌─────────────────────────────────────────────┐
                    │         VPC Lattice Service Network         │
                    │              (IAM Auth)                     │
                    │                                             │
                    │ ┌─────────────────────────────────────────┐ │
                    │ │           API Service                   │ │
                    │ │  (Path-based routing to multiple TGs)  │ │
                    │ └─────────────────────────────────────────┘ │
                    │ ┌─────────────────────────────────────────┐ │
                    │ │         Products Service                │ │
                    │ │     (Weighted routing v1/v2)           │ │
                    │ └─────────────────────────────────────────┘ │
                    └─────────────────────────────────────────────┘
```

## Features

- Three VPCs with different service types
- Path-based routing for API service
- Weighted routing for products service
- Multiple target types: Lambda, ALB, ECS Fargate, EC2, IP targets
- Web interface for testing services
- IAM authentication and custom domains

## Services

### API Service (Path-based routing)

- `/orders` → Lambda orders service
- `/payments` → Lambda payments service
- `/inventory` → Lambda inventory service
- `/analytics` → ECS Fargate analytics service
- `/notifications` → EC2 notifications service
- `/health` → EC2 health service (IP target)
- Default → Lambda notfound service

### Products Service (Weighted routing)

- 50% traffic → Products service v1 (Lambda)
- 50% traffic → Products service v2 (Lambda)

### EC2 Services

- **Jumphost**: SSH access for command-line testing
- **Web Server**: Web interface with interactive buttons to test all services
- **Notifications Service**: EC2-hosted nginx service responding to `/notifications` path
- **Health Service**: EC2-hosted nginx service responding to `/health` path (IP target)

## Usage

### Deploy

```bash
terraform init
terraform plan
terraform apply
```

### Test

#### Option 1: Web Interface (Recommended)

Access the web interface at the Web Server's public IP:

1. Get the Web Server public IP from Terraform output
2. Open `https://<web-server-ip>` in your browser
3. Use the interactive buttons to test all services
4. View detailed responses and debug information

#### Option 2: Command Line

SSH to the jumphost and test different endpoints:

```bash
# Test API service with path-based routing
curl api.example.local/orders
curl api.example.local/payments
curl api.example.local/inventory
curl api.example.local/analytics
curl api.example.local/notifications
curl api.example.local/health

# Test products service with weighted routing
curl products.example.local
```

Expected responses:

- Orders: `{"service":"orders","message":"Order processed"}`
- Payments: `{"service":"payments","message":"Payment processed"}`
- Notifications: `{"service":"notifications-service","message":"Notifications Service (EC2)","notifications":[...]}`
- Health: `{"status":"healthy","service":"health-service","timestamp":"2024-01-15T10:30:00Z"}`
- Products: `{"service":"products","version":"v1"}` or `{"service":"products","version":"v2"}`

## Configuration

### Path-based Routing

```hcl
listener_rules = [
  {
    priority          = 20
    target_group_name = "orders-service"
    match = {
      http_match = {
        path = "/orders"
      }
    }
  },
  {
    priority          = 30
    target_group_name = "payments-service"
    match = {
      http_match = {
        path = "/payments"
      }
    }
  }
]
```

### Weighted Routing

```hcl
target_groups = [
  {
    name   = "products-service-v1"
    type   = "LAMBDA"
    weight = 50
    targets = [
      {
        target_id = module.lambda_products_service.arn
      }
    ]
  },
  {
    name   = "products-service-v2"
    type   = "LAMBDA"
    weight = 50
    targets = [
      {
        target_id = module.lambda_products_service_v2.arn
      }
    ]
  }
]
```

## Cleanup

```bash
terraform destroy
```
