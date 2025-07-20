############################################
# Terraform & Provider Configuration
############################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

############################################
# Data Sources
############################################

data "aws_region" "current" {}

############################################
# Random Suffix for Resource Names
############################################

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

############################################
# Local Variables
############################################

locals {
  # VPC 1 Configuration
  azs_1             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  name_1            = "cltest1"
  base_name_1       = "${local.name_1}-${random_string.suffix.result}"
  private_subnets_1 = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_subnets_1  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  vpc_cidr_1        = "10.0.0.0/16"

  # VPC 2 Configuration
  azs_2             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  name_2            = "cltest2"
  base_name_2       = "${local.name_2}-${random_string.suffix.result}"
  private_subnets_2 = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
  public_subnets_2  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  vpc_cidr_2        = "10.1.0.0/16"

  # Common tags
  suffix = random_string.suffix.result

  # If this does not work, use "169.254.0.0/16"
  vpc_lattice_cidr = "169.254.171.0/24"

  tags_1 = {
    Environment = "dev"
    VPC         = "client"
  }

  tags_2 = {
    Environment = "dev"
    VPC         = "ec2-web"
  }
}

# Get current user's public IP
data "http" "my_public_ip" {
  url = "https://checkip.amazonaws.com/"
}
