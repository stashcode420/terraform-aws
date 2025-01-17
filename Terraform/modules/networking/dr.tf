# infrastructure/modules/networking/dr.tf
# DR VPC and related resources
module "dr_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  providers = {
    aws = aws.dr
  }

  name = "${local.name}-dr-vpc"
  cidr = var.dr_vpc_cidr

  azs              = var.dr_azs
  public_subnets   = var.dr_public_subnets
  private_subnets  = var.dr_private_app_subnets
  database_subnets = var.dr_private_db_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.tags, {
    Environment = "${var.environment}-dr"
  })
}

# VPC Peering between primary and DR
resource "aws_vpc_peering_connection" "primary_dr" {
  count = var.enable_vpc_peering ? 1 : 0

  vpc_id      = module.vpc.vpc_id
  peer_vpc_id = module.dr_vpc.vpc_id
  peer_region = var.dr_region
  auto_accept = false

  tags = merge(local.tags, {
    Name = "${local.name}-primary-dr-peering"
  })
}

# Accept VPC peering connection in DR region
resource "aws_vpc_peering_connection_accepter" "dr" {
  count = var.enable_vpc_peering ? 1 : 0

  provider                  = aws.dr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_dr[0].id
  auto_accept               = true

  tags = merge(local.tags, {
    Name = "${local.name}-dr-primary-peering"
  })
}

# Route tables for VPC peering
resource "aws_route" "primary_to_dr" {
  count = var.enable_vpc_peering ? length(module.vpc.private_route_table_ids) : 0

  route_table_id            = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.dr_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_dr[0].id
}

resource "aws_route" "dr_to_primary" {
  count = var.enable_vpc_peering ? length(module.dr_vpc.private_route_table_ids) : 0

  provider                  = aws.dr
  route_table_id            = module.dr_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_dr[0].id
}

# DR Transit Gateway attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "dr" {
  provider = aws.dr

  subnet_ids         = module.dr_vpc.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.dr_vpc.vpc_id

  tags = merge(local.tags, {
    Name = "${local.name}-dr-tgw-attachment"
  })
}

# Cross-region DNS resolution
resource "aws_route53_zone_association" "primary_dr" {
  count = var.enable_vpc_peering ? 1 : 0

  zone_id    = aws_route53_private_hosted_zone.main.zone_id
  vpc_id     = module.dr_vpc.vpc_id
  vpc_region = var.dr_region
}
