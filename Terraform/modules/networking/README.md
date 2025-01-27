# Networking Module

## Overview

This module sets up the AWS networking infrastructure for the trading platform, including VPC, subnets, Transit Gateway, and related components.

## Features

- VPC with public, private app, and private DB subnets
- NAT Gateways for outbound internet access
- Transit Gateway for inter-region connectivity
- VPC Endpoints for AWS services
- Network Firewall (optional)
- VPN Gateway (optional)
- VPC Flow Logs
- Security Groups

## Usage

```hcl
module "networking" {
  source = "../../modules/networking"

  environment = "prod"
  region      = "us-east-1"
  project     = "trading-platform"

  vpc_cidr = "10.0.0.0/16"
  # ... other variables
}
```
