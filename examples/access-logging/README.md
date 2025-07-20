# VPC Lattice Access Logging Example

A simple example showing VPC Lattice with access logging enabled.

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
                    │      Network (IAM Auth)     │
                    │                             │
                    │ ┌─────────────────────────┐ │
                    │ │   Lambda API Service    │ │
                    │ │   (Access Logging)      │ │
                    │ └─────────────────────────┘ │
                    └─────────────────────────────┘
```

## Features

- Two VPCs with Lambda service in VPC 2
- VPC Lattice service network with IAM auth
- Access logging enabled for monitoring
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
curl http://<vpc-lattice-service-dns>

# Test custom domain
curl http://api.example.local
```

Expected response: `Hello from VPC Lattice with Access Logging!`

### Monitor

Check CloudWatch logs:

- Service Network: `/aws/vpclattice/<service-network-name>`
- Service: `/aws/vpclattice/<service-name>`

## Cleanup

```bash
terraform destroy
```
