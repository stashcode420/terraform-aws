# modules/eks/trading_node_groups.tf

locals {
  trading_node_groups = {
    arbiters = {
      instance_types = ["c6i.2xlarge"] # CPU optimized for calculations
      capacity_type  = "ON_DEMAND"
      desired_size   = 3
      min_size       = 2
      max_size       = 5
      disk_size      = 100
      labels = {
        "role"     = "arbiter"
        "workload" = "trading"
      }
      taints = [{
        key    = "workload"
        value  = "arbiter"
        effect = "NO_SCHEDULE"
      }]
    }

    market_data = {
      instance_types = ["r6i.2xlarge"] # Memory optimized for market data
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      min_size       = 2
      max_size       = 4
      disk_size      = 200
      labels = {
        "role"     = "market-data"
        "workload" = "trading"
      }
      taints = [{
        key    = "workload"
        value  = "market-data"
        effect = "NO_SCHEDULE"
      }]
    }

    executors = {
      instance_types = ["c6i.xlarge"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      min_size       = 2
      max_size       = 4
      disk_size      = 100
      labels = {
        "role"     = "executor"
        "workload" = "trading"
      }
      taints = [{
        key    = "workload"
        value  = "executor"
        effect = "NO_SCHEDULE"
      }]
    }

    websocket = {
      instance_types = ["c6i.large"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      min_size       = 2
      max_size       = 4
      disk_size      = 50
      labels = {
        "role"     = "websocket"
        "workload" = "trading"
      }
      taints = []
    }
  }
}
