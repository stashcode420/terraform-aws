# modules/eks/backup.tf

resource "aws_eks_addon" "velero" {
  cluster_name      = aws_eks_cluster.main.name
  addon_name        = "velero"
  addon_version     = "1.8.0-eksbuild.1"
  resolve_conflicts = "OVERWRITE"

  tags = local.tags
}

resource "aws_s3_bucket" "velero" {
  bucket = "${local.name}-velero-backup"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 90
    }
  }

  tags = local.tags
}

resource "aws_iam_role_policy" "velero" {
  name = "velero-backup"
  role = aws_iam_role.velero.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.velero.arn,
          "${aws_s3_bucket.velero.arn}/*"
        ]
      }
    ]
  })
}
