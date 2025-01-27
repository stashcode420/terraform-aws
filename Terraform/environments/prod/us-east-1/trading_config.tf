# infrastructure/environments/prod/us-east-1/trading_config.tf

locals {
  trading_config = {
    market_data = {
      feeds = ["primary", "backup"]
      ports = [8000, 8001, 8002]
      cidrs = ["10.100.0.0/24", "10.100.1.0/24"]
    }

    fix_protocol = {
      ports              = [5000, 5001]
      allowed_ips        = ["192.168.1.0/24"]
      session_qualifiers = ["FIX.4.2", "FIX.4.4"]
    }

    trading_engine = {
      latency_threshold_ms = 10
      rate_limits = {
        orders_per_second  = 1000
        cancels_per_second = 500
      }
    }

    risk_checks = {
      enable_pre_trade   = true
      enable_post_trade  = true
      max_order_value    = 1000000
      max_position_value = 10000000
    }
  }
}
