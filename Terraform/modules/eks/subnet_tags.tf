# modules/eks/subnet_tags.tf

resource "aws_ec2_tag" "private_subnet_cluster" {
  for_each    = toset(data.aws_subnets.private.ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${local.name}"
  value       = "shared"
}

resource "aws_ec2_tag" "private_subnet_elb" {
  for_each    = toset(data.aws_subnets.private.ids)
  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}