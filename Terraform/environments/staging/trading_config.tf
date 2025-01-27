locals {
  trading_config = {
    market_data = {
      feeds = ["primary", "backup"]
      ports = [8000, 8001]
      cidrs = ["10.2.0.0/24"]
    }

    fix_protocol = {
      ports              = [5000, 5001]
      allowed_ips        = ["192.168.1.0/24"]
      session_qualifiers = ["FIX.4.2", "FIX.4.4"]
    }

    trading_engine = {
      latency_threshold_ms = 50
      rate_limits = {
        orders_per_second  = 500
        cancels_per_second = 250
      }
    }
  }
}
