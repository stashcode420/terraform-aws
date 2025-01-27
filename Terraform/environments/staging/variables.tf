# infrastructure/environments/prod/us-east-1/variables.tf

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "trading_platform_config" {
  description = "Trading platform specific configurations"
  type = object({
    market_data = object({
      feeds                   = list(string)
      ports                   = list(number)
      cidrs                   = list(string)
      redundancy_level        = string
      data_retention_days     = number
      backup_interval_minutes = number
    })

    fix_protocol = object({
      ports                = list(number)
      allowed_ips          = list(string)
      session_qualifiers   = list(string)
      heartbeat_interval   = number
      reconnect_interval   = number
      max_session_duration = number
    })

    trading_engine = object({
      latency_threshold_ms = number
      rate_limits = object({
        orders_per_second        = number
        cancels_per_second       = number
        modifications_per_second = number
      })
      circuit_breakers = object({
        price_deviation_percent = number
        volume_multiplier       = number
        cool_down_period        = number
      })
    })

    risk_management = object({
      pre_trade_checks    = list(string)
      post_trade_checks   = list(string)
      exposure_limits     = map(number)
      margin_requirements = map(number)
      alert_thresholds    = map(number)
    })
  })

  default = {
    market_data = {
      feeds                   = ["primary", "backup", "fallback"]
      ports                   = [8000, 8001, 8002]
      cidrs                   = ["10.0.0.0/24", "10.0.1.0/24"]
      redundancy_level        = "high"
      data_retention_days     = 90
      backup_interval_minutes = 5
    }

    fix_protocol = {
      ports                = [5000, 5001]
      allowed_ips          = ["192.168.1.0/24"]
      session_qualifiers   = ["FIX.4.2", "FIX.4.4"]
      heartbeat_interval   = 30
      reconnect_interval   = 5
      max_session_duration = 86400
    }

    trading_engine = {
      latency_threshold_ms = 10
      rate_limits = {
        orders_per_second        = 1000
        cancels_per_second       = 500
        modifications_per_second = 200
      }
      circuit_breakers = {
        price_deviation_percent = 10
        volume_multiplier       = 3
        cool_down_period        = 300
      }
    }

    risk_management = {
      pre_trade_checks = [
        "margin_check",
        "position_limit",
        "order_size",
        "price_tolerance"
      ]
      post_trade_checks = [
        "exposure_aggregation",
        "risk_factor_calculation"
      ]
      exposure_limits = {
        max_order_notional    = 1000000
        max_position_notional = 10000000
        max_daily_loss        = 500000
      }
      margin_requirements = {
        initial_margin     = 10.0
        maintenance_margin = 7.5
        variation_margin   = 5.0
      }
      alert_thresholds = {
        utilization_warning  = 80
        utilization_critical = 90
      }
    }
  }
}
