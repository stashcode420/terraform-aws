variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "repository_names" {
  description = "List of ECR repository names"
  type        = list(string)
}