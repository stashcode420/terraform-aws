# modules/eks/key_pairs.tf

# Generate key pair
resource "tls_private_key" "node" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "node" {
  key_name_prefix = "${local.name}-node-"
  public_key      = tls_private_key.node.public_key_openssh

  tags = local.tags
}

# Store private key in Secrets Manager
resource "aws_secretsmanager_secret" "node_key" {
  name_prefix = "${local.name}-node-key-"
  description = "EKS node SSH private key"

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "node_key" {
  secret_id = aws_secretsmanager_secret.node_key.id
  secret_string = jsonencode({
    private_key = tls_private_key.node.private_key_pem
    public_key  = tls_private_key.node.public_key_openssh
  })
}