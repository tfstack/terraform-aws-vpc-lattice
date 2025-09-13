# VPC Lattice Rules Example

This example demonstrates how to use VPC Lattice with listener rules for content-based routing in a realistic e-commerce microservices architecture.

## Architecture

```plaintext
┌─────────────────┐                          ┌─────────────────┐
│      VPC 1      │                          │      VPC 2      │
│   (Client)      │                          │   (Backend)     │
│                 │                          │                 │
│ ┌─────────────┐ │                          │ ┌─────────────┐ │
│ │  Jumphost   │ │                          │ │   Lambda    │ │
│ │   (Test)    │ │                          │ │  Functions  │ │
│ └─────────────┘ │                          │ │             │ │
└─────────────────┘                          │ │ • Products  │ │
         │                                   │ │ • Orders    │ │
         │                                   │ │ • Payments  │ │
         │                                   │ │ • Inventory │ │
         │                                   │ │ • Analytics │ │
         │                                   │ │ • Not Found │ │
         │                                   │ └─────────────┘ │
         │                                   └─────────────────┘
         │                                           │
         └───────────────────────────────────────────┼───────┐
                                                     │       │
                    ┌─────────────────────────────────────────┐
                    │         VPC Lattice Service Network     │
                    │              (ecommerce.local)          │
                    │                                         │
                    │ ┌─────────────────────────────────────┐ │
                    │ │           API Service               │ │
                    │ │  (Path-based routing with rules)   │ │
                    │ └─────────────────────────────────────┘ │
                    └─────────────────────────────────────────┘
```

## Features

- **Multi-VPC Architecture**: Two separate VPCs with isolated networking
- **Path-based Routing**: Content-based routing using listener rules
- **E-commerce Microservices**: Six specialized Lambda functions for different business domains
- **Custom Domain**: Internal domain `api.ecommerce.local`
- **Error Handling**: 404 service for unmatched requests

## Services

### API Service (Path-based routing)

- `/products` → Products Service
- `/orders` → Orders Service
- `/payments` → Payments Service
- `/inventory` → Inventory Service
- `/analytics` → Analytics Service
- Default → Not Found Service

### EC2 Services

- **Jumphost**: SSH access for command-line testing and debugging

## Usage

### Deploy

```bash
terraform init
terraform plan
terraform apply
```

### Test

SSH to the jumphost and test different endpoints:

```bash
# Test all business domain services
curl api.ecommerce.local/products
curl api.ecommerce.local/orders
curl api.ecommerce.local/payments
curl api.ecommerce.local/inventory
curl api.ecommerce.local/analytics

# Test 404 handling
curl api.ecommerce.local/unknown
```

Expected responses:

- **Products**: `{"service":"products","message":"Product catalog service","products":[...]}`
- **Orders**: `{"service":"orders","message":"Order management service","orders":[...]}`
- **Payments**: `{"service":"payments","message":"Payment processing service","payments":[...]}`
- **Inventory**: `{"service":"inventory","message":"Inventory management service","inventory":[...]}`
- **Analytics**: `{"service":"analytics","message":"Business intelligence service","metrics":[...]}`
- **404**: `{"error":"Not Found","message":"The requested endpoint does not exist",...}`

## Configuration

### Listener Rules Setup

```hcl
listener_rules = [
  {
    priority          = 10
    target_group_name = "products-service"
    match = {
      http_match = {
        path = "/products"
      }
    }
  },
  {
    priority          = 20
    target_group_name = "orders-service"
    match = {
      http_match = {
        path = "/orders"
      }
    }
  }
  # ... additional rules for payments, inventory, analytics
]
```

### Lambda Target Group Configuration

```hcl
target_groups = [
  {
    name                           = "products-service"
    type                           = "LAMBDA"
    lambda_event_structure_version = "V1"
    targets = [
      {
        target_id = aws_lambda_function.products_handler.arn
      }
    ]
  }
]
```

## Cleanup

```bash
terraform destroy
```

## Important Notes

### VPC Lattice Features

- **Service Network**: Single service network connecting both VPCs
- **Listener Rules**: Path-based routing with priority evaluation
- **Default Action**: Routes unmatched requests to 404 service
- **Custom Domain**: Route 53 zone `ecommerce.local` for internal DNS resolution

### Security Considerations

- **VPC Isolation**: Each VPC has separate security groups
- **No Authentication**: Uses `auth_type = "NONE"` for simplicity
- **Cross-VPC Access**: VPC Lattice handles inter-VPC routing securely
- **Network Isolation**: VPCs remain isolated except through VPC Lattice

## Troubleshooting

### Common Issues

1. **Lambda invocation errors**: Verify IAM roles and VPC Lattice service network associations
2. **DNS resolution issues**: Check Route 53 zone configuration and VPC associations
3. **Security group conflicts**: Ensure security groups allow necessary traffic for VPC Lattice

### Debugging

1. **Check Lambda logs**: CloudWatch Logs for function execution
2. **VPC Lattice logs**: CloudWatch Logs for service mesh traffic
3. **Network connectivity**: Verify VPC routing and security groups

## Extending the Example

This example can be extended with:

- **Database Integration**: Add RDS or DynamoDB for persistent data storage
- **Authentication**: Implement JWT or OAuth for user authentication
- **API Gateway**: Add API Gateway for external API management
- **Monitoring**: Add CloudWatch dashboards and alarms for business metrics
- **Event-Driven Architecture**: Add SQS/SNS for asynchronous communication
