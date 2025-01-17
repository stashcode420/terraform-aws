locals {
  trading_config = {
    market_data = {
      feeds = ["primary"]
      ports = [8000]
      cidrs = ["10.1.0.0/24"]
    }

    fix_protocol = {
      ports              = [5000]
      allowed_ips        = ["192.168.1.0/24"]
      session_qualifiers = ["FIX.4.2"]
    }

    trading_engine = {
      latency_threshold_ms = 100 # More relaxed for dev
      rate_limits = {
        orders_per_second  = 100
        cancels_per_second = 50
      }
    }
  }
}
