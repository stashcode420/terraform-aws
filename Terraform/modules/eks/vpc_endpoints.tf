# modules/eks/vpc_endpoints.tf

# EKS VPC Endpoint
resource "aws_vpc_endpoint" "eks" {
  vpc_id             = data.aws_vpc.existing.id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.eks"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = data.aws_subnets.private.ids
  security_group_ids = [aws_security_group.cluster.id]

  private_dns_enabled = false
  tags               = local.tags
}

# ECR Docker VPC Endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = data.aws_vpc.existing.id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = data.aws_subnets.private.ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  private_dns_enabled = false
  tags               = local.tags
}

# ECR API VPC Endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = data.aws_vpc.existing.id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = data.aws_subnets.private.ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  private_dns_enabled = false
  tags               = local.tags
}

# S3 VPC Endpoint (Gateway type)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = data.aws_vpc.existing.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = data.aws_route_tables.private.ids

  tags = local.tags
}

# Security group for VPC endpoints
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${local.name}-vpc-endpoints"
  vpc_id      = data.aws_vpc.existing.id
  description = "Security group for VPC endpoints"

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-vpc-endpoints"
    }
  )
}

# Validation check
resource "null_resource" "validate_vpc_config" {
  lifecycle {
    precondition {
      condition     = length(data.aws_subnets.private.ids) >= 2
      error_message = "At least 2 private subnets are required for EKS cluster deployment."
    }
  }
}