############################################
# VPC Configuration
############################################

module "vpc_1" {
  source = "cloudbuildlab/vpc/aws"

  vpc_name           = local.base_name_1
  vpc_cidr           = local.vpc_cidr_1
  availability_zones = local.azs_1

  public_subnet_cidrs  = local.public_subnets_1
  private_subnet_cidrs = local.private_subnets_1

  # Enable Internet Gateway & NAT Gateway
  create_igw       = true
  nat_gateway_type = "single"

  tags = local.tags_1
}

module "vpc_2" {
  source = "cloudbuildlab/vpc/aws"

  vpc_name           = local.base_name_2
  vpc_cidr           = local.vpc_cidr_2
  availability_zones = local.azs_2

  public_subnet_cidrs  = local.public_subnets_2
  private_subnet_cidrs = local.private_subnets_2

  # Enable Internet Gateway & NAT Gateway
  create_igw       = true
  nat_gateway_type = "single"

  tags = local.tags_2
}

module "vpc_3" {
  source = "cloudbuildlab/vpc/aws"

  vpc_name           = local.base_name_3
  vpc_cidr           = local.vpc_cidr_3
  availability_zones = local.azs_3

  public_subnet_cidrs  = local.public_subnets_3
  private_subnet_cidrs = local.private_subnets_3

  # Enable Internet Gateway & NAT Gateway
  create_igw       = true
  nat_gateway_type = "single"

  tags = local.tags_3
}

############################################
# Security Groups
############################################

resource "aws_security_group" "ec2_client_sg" {
  name        = "${local.base_name_1}-ec2-client-sg"
  description = "Security group for ec2 client"
  vpc_id      = module.vpc_1.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags_2, {
    Name = "${local.base_name_1}-ec2-client-sg"
  })
}

resource "aws_security_group" "lambda_sg" {
  name        = "${local.base_name_2}-lambda-sg"
  description = "Security group for lambda"
  vpc_id      = module.vpc_2.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = module.vpc_2.private_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags_2, {
    Name = "${local.base_name_2}-lambda-sg"
  })
}

resource "aws_security_group" "vpc_lattice_2_sg" {
  name        = "${local.base_name_2}-vpc-lattice-sg"
  description = "Security group for VPC Lattice 2"
  vpc_id      = module.vpc_2.vpc_id

  ingress {
    description = "Allow HTTP port 80 access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc_2.vpc_cidr, local.vpc_lattice_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags_2, {
    Name = "${local.base_name_2}-vpc-lattice-sg"
  })
}

resource "aws_security_group" "web_server_sg" {
  name        = "${local.base_name_1}-web-server-sg"
  description = "Security group for web server EC2"
  vpc_id      = module.vpc_1.vpc_id

  ingress {
    description = "Allow HTTP port 80 access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS port 443 access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags_1, {
    Name = "${local.base_name_1}-web-server-sg"
  })
}

resource "aws_security_group" "fargate_sg" {
  name   = "${local.base_name_3}-fargate-sg"
  vpc_id = module.vpc_3.vpc_id

  ingress {
    description = "Allow HTTP port 8000 access"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [module.vpc_3.vpc_cidr, local.vpc_lattice_cidr]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags_3
}

resource "aws_security_group" "notifications_service_sg" {
  name   = "${local.base_name_3}-notifications-service-sg"
  vpc_id = module.vpc_3.vpc_id

  ingress {
    description = "Allow HTTP port 80 access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc_3.vpc_cidr, local.vpc_lattice_cidr]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags_3
}

resource "aws_security_group" "ec2_health_service_sg" {
  name   = "${local.base_name_3}-health-service-sg"
  vpc_id = module.vpc_3.vpc_id

  ingress {
    description = "Allow HTTP port 80 access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc_3.vpc_cidr, local.vpc_lattice_cidr]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags_3
}

resource "aws_security_group" "vpc_lattice_3_sg" {
  name        = "${local.base_name_3}-vpc-lattice-sg"
  description = "Security group for VPC Lattice 3"
  vpc_id      = module.vpc_3.vpc_id

  ingress {
    description = "Allow HTTP port 80 access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc_3.vpc_cidr, local.vpc_lattice_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags_3, {
    Name = "${local.base_name_3}-vpc-lattice-sg"
  })
}
