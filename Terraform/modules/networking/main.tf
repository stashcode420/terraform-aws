# main.tf

locals {
  name = "${var.project}-${var.environment}"

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr

  azs              = var.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_app_subnets
  database_subnets = var.private_db_subnets

  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true

  # VPC Flow Logs
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

# Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  description = "${local.name}-tgw"

  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-tgw"
    }
  )
}

# VPC attachment to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  subnet_ids         = module.vpc.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.vpc.vpc_id

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-tgw-attachment"
    }
  )
}

# Security Group for EKS Cluster
resource "aws_security_group" "eks_cluster" {
  name_prefix = "${local.name}-eks-cluster"
  description = "Security group for EKS cluster"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-eks-cluster-sg"
    }
  )
}

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${local.name}-vpc-endpoints"
  description = "Security group for VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
    description     = "Allow HTTPS from EKS cluster"
  }

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-vpc-endpoints-sg"
    }
  )
}

# VPN Gateway (if enabled)
resource "aws_vpn_gateway" "main" {
  count = var.enable_vpn_gateway ? 1 : 0

  vpc_id = module.vpc.vpc_id

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-vpn-gateway"
    }
  )
}