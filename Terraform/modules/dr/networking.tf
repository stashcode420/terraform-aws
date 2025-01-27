# modules/dr/networking.tf
# VPC Peering between regions
resource "aws_vpc_peering_connection" "primary_dr" {
  vpc_id      = var.primary_vpc_id
  peer_vpc_id = var.dr_vpc_id
  peer_region = var.dr_region
  auto_accept = false

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-primary-dr-peering"
  })
}

resource "aws_vpc_peering_connection_accepter" "dr" {
  provider                  = aws.dr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_dr.id
  auto_accept               = true

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-dr-accepter"
  })
}
