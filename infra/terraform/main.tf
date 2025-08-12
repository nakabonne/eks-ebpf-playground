provider "aws" {
  region = var.region
}

locals {
  # Split version (e.g. 1.33 or 1.32.1) and extract minor component for comparison
  version_parts     = split(".", var.kubernetes_version)
  minor_version_num = tonumber(element(local.version_parts, 1))

  # Determine default AMI type based on Kubernetes minor version.
  # AL2 images are supported only up to 1.32; for 1.33+ we must use AL2023.
  # Valid AL2023 enumeration requires the _STANDARD suffix.
  default_ami_type = local.minor_version_num >= 33 ? "AL2023_x86_64_STANDARD" : "AL2_x86_64"

  # Allow manual override via var.ami_type; otherwise use computed default.
  resolved_ami_type = var.ami_type != "" ? var.ami_type : local.default_ami_type
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = true  # Use single NAT gateway for cost optimization

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = var.tags
}

# EKS Cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    main = {
      name = "main"

      instance_types = var.node_instance_types
      capacity_type  = "ON_DEMAND"

      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size
      # Automatically pick suitable AMI unless overridden.
      ami_type     = local.resolved_ami_type

      # Enable IMDSv2
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }

      tags = var.tags
    }
  }

  tags = var.tags
}
