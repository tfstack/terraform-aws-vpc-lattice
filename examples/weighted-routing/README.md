# VPC Lattice Weighted Routing Example

This example demonstrates how to use VPC Lattice to implement weighted routing across multiple target types including EC2 instances (both INSTANCE and IP targets), Application Load Balancers, and Lambda functions.

## Architecture

```plaintext
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      VPC 1      │    │      VPC 2      │    │      VPC 3      │
│   (Client)      │    │   (EC2 Web)     │    │   (ALB Web)     │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │  Jumphost   │ │    │ │ EC2 Server 1│ │    │ │ EC2 Server 3│ │
│ │   (Test)    │ │    │ │   (15%)     │ │    │ │   (15%)     │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │   Lambda    │ │    │ │ EC2 Server 2│ │    │ │     ALB     │ │
│ │   (15%)     │ │    │ │   (15%)     │ │    │ │   (25%)     │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
│                 │    │ ┌─────────────┐ │    │                 │
│                 │    │ │ EC2 Server 4│ │    │                 │
│                 │    │ │   (15%)     │ │    │                 │
│                 │    │ └─────────────┘ │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┼───────┐
                                 │                       │       │
                    ┌─────────────────────────────────────────────┐
                    │         VPC Lattice Service Network         │
                    │              (example.local)                │
                    │                                             │
                    │ ┌─────────────────────────────────────────┐ │
                    │ │           Web Service                   │ │
                    │ │        (Weighted Routing)               │ │
                    │ └─────────────────────────────────────────┘ │
                    └─────────────────────────────────────────────┘
```

## Features

- **Multi-VPC Architecture**: Three separate VPCs with different target types
- **Weighted Routing**: Traffic distribution across 6 target groups (15% each for EC2/Lambda, 25% for ALB)
- **Mixed Target Types**: EC2 instances (INSTANCE and IP targets), ALB, and Lambda function
- **Custom Domain**: Internal domain `web.example.local`
- **Health Checks**: Comprehensive health monitoring for all targets

## Services

### Web Service (Weighted routing)

- **15%** → EC2 Web Server 1 (VPC 2) - INSTANCE target
- **15%** → EC2 Web Server 2 (VPC 2) - INSTANCE target
- **15%** → EC2 Web Server 3 (VPC 2) - IP target (port 8080)
- **15%** → EC2 Web Server 4 (VPC 2) - IP target (port 8080)
- **25%** → ALB with EC2 instances (VPC 3)
- **15%** → Lambda function (VPC 1)

### EC2 Services

- **Jumphost**: SSH access for testing and debugging
- **Web Servers 1 & 2**: Apache HTTP servers on port 80 (INSTANCE targets)
- **Web Servers 3 & 4**: Apache HTTP servers on port 8080 (IP targets)
- **ALB**: Internal Application Load Balancer with health checks

## Usage

### Deploy

```bash
terraform init
terraform plan
terraform apply
```

### Test

SSH to the jumphost and test the weighted routing:

```bash
# Test weighted routing (run multiple times to see different targets)
for i in {1..10}; do
  echo "Request $i:"
  curl -s web.example.local
  echo -e "\n---"
done

# Test via VPC Lattice DNS
curl $(terraform output -raw vpc_lattice_service_dns)

# Test via custom domain
curl web.example.local
```

Expected responses:

- **EC2 Server 1**: `Hello from cltest2-xxxx-ec2-web-server-1 in VPC2!`
- **EC2 Server 2**: `Hello from cltest2-xxxx-ec2-web-server-2 in VPC2!`
- **EC2 Server 3**: `Hello from cltest2-xxxx-ec2-web-server-3 in VPC2!` (IP target)
- **EC2 Server 4**: `Hello from cltest2-xxxx-ec2-web-server-4 in VPC2!` (IP target)
- **ALB**: `Hello from cltest3-xxxx-ec2-web-server-3 in VPC3!`
- **Lambda**: `{"message":"Hello from cltest1-xxxx-lambda in VPC1!","timestamp":"..."}`

## Configuration

### Weighted Target Groups

```hcl
target_groups = [
  {
    name     = "ec2-web-server-1"
    type     = "INSTANCE"
    weight   = 15
    targets  = [module.ec2_web_server_1.instance_id]
  },
  {
    name     = "ec2-web-server-2"
    type     = "INSTANCE"
    weight   = 15
    targets  = [module.ec2_web_server_2.instance_id]
  },
  {
    name     = "ec2-web-server-3"
    type     = "IP"
    weight   = 15
    targets  = [{ target_id = module.ec2_web_server_3.private_ip, port = 8080 }]
  },
  {
    name     = "ec2-web-server-4"
    type     = "IP"
    weight   = 15
    targets  = [{ target_id = module.ec2_web_server_4.private_ip, port = 8080 }]
  },
  {
    name     = "alb-web-server-1"
    type     = "ALB"
    weight   = 25
    targets  = [module.alb.alb_arn]
  },
  {
    name     = "lambda-api-1"
    type     = "LAMBDA"
    weight   = 15
    lambda_event_structure_version = "V1"
    targets  = [aws_lambda_function.api_handler.arn]
  }
]
```

## Cleanup

```bash
terraform destroy
```

## Important Notes

### VPC Lattice Features

- **Service Network**: Single service network connecting all three VPCs
- **Weighted Routing**: Distribution across six target groups (15% each for EC2/Lambda, 25% for ALB)
- **Mixed Target Types**: Demonstrates both INSTANCE and IP target types
- **Custom Domain**: Route 53 zone `example.local` for internal DNS resolution
- **Health Checks**: All target groups have health checks enabled

### Security Considerations

- **VPC Isolation**: Each VPC has separate security groups
- **ALB Security**: ALB allows VPC Lattice traffic via CIDR `169.254.0.0/16`
- **Cross-VPC Access**: VPC Lattice handles inter-VPC routing securely
- **No Public Access**: All resources are in private subnets

## Troubleshooting

### Common Issues

1. **Service Unavailable errors**: Check ALB security group allows VPC Lattice traffic
2. **EC2 not responding**: Verify security groups and health checks
3. **ALB health check failures**: Ensure `/health` endpoint exists
4. **VPC Lattice connection**: Verify VPC associations and security groups
5. **DNS resolution**: Ensure Route 53 zone is properly configured

### Debugging

1. **Check EC2 logs**: SSH into instances to verify web server status
2. **ALB health checks**: Verify target group health status
3. **VPC Lattice logs**: CloudWatch Logs for service mesh traffic
4. **Network connectivity**: Verify VPC routing and security groups
5. **Security groups**: Ensure proper ingress/egress rules

## Extending the Example

This example can be extended with:

- **Auto Scaling Groups**: Replace static EC2 instances
- **ECS/Fargate**: Add containerized services
- **Additional IP Targets**: Add more IP-based target groups for microservices
- **Authentication**: Use VPC Lattice auth policies
- **Listener rules**: Path-based routing within services
- **Custom domain certificates**: HTTPS support
- **Monitoring and alerting**: Performance and health monitoring
