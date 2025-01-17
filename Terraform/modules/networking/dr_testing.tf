# infrastructure/modules/networking/dr_testing.tf

# DR Test Scenarios State Machine
resource "aws_sfn_state_machine" "dr_testing" {
  name     = "${local.name}-dr-testing"
  role_arn = aws_iam_role.dr_testing.arn

  definition = jsonencode({
    StartAt = "SelectTestScenario"
    States = {
      SelectTestScenario = {
        Type = "Choice"
        Choices = [
          {
            Variable     = "$.testType"
            StringEquals = "MARKET_DATA_DISRUPTION"
            Next         = "TestMarketDataFailover"
          },
          {
            Variable     = "$.testType"
            StringEquals = "ORDER_EXECUTION_FAILURE"
            Next         = "TestOrderExecutionFailover"
          },
          {
            Variable     = "$.testType"
            StringEquals = "DATABASE_SYNC_FAILURE"
            Next         = "TestDatabaseFailover"
          },
          {
            Variable     = "$.testType"
            StringEquals = "NETWORK_PARTITION"
            Next         = "TestNetworkFailover"
          }
        ]
      },

      TestMarketDataFailover = {
        Type = "Parallel"
        Branches = [
          {
            StartAt = "SimulateMarketDataDisruption"
            States = {
              SimulateMarketDataDisruption = {
                Type     = "Task"
                Resource = aws_lambda_function.simulate_market_data_failure.arn
                Next     = "ValidateBackupFeeds"
              },
              ValidateBackupFeeds = {
                Type     = "Task"
                Resource = aws_lambda_function.validate_market_data.arn
                Next     = "VerifyDataConsistency"
              },
              VerifyDataConsistency = {
                Type     = "Task"
                Resource = aws_lambda_function.verify_data_consistency.arn
                End      = true
              }
            }
          }
        ],
        Next = "EvaluateTestResults"
      },

      TestOrderExecutionFailover = {
        Type = "Parallel"
        Branches = [
          {
            StartAt = "SimulateExecutionFailure"
            States = {
              SimulateExecutionFailure = {
                Type     = "Task"
                Resource = aws_lambda_function.simulate_execution_failure.arn
                Next     = "ValidateOrderRouting"
              },
              ValidateOrderRouting = {
                Type     = "Task"
                Resource = aws_lambda_function.validate_order_routing.arn
                Next     = "VerifyOrderStatus"
              },
              VerifyOrderStatus = {
                Type     = "Task"
                Resource = aws_lambda_function.verify_order_status.arn
                End      = true
              }
            }
          }
        ],
        Next = "EvaluateTestResults"
      },

      EvaluateTestResults = {
        Type     = "Task"
        Resource = aws_lambda_function.evaluate_dr_test.arn
        End      = true
      }
    }
  })
}

# DR Test Functions
resource "aws_lambda_function" "dr_test_suite" {
  filename      = "dr_test_suite.zip"
  function_name = "${local.name}-dr-test-suite"
  role          = aws_iam_role.dr_test.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  timeout       = 300

  environment {
    variables = {
      TEST_SCENARIOS = jsonencode({
        market_data = {
          disruption_duration = "300"
          validation_points   = ["price_feed", "order_book", "trade_feed"]
        },
        order_execution = {
          test_orders         = ["market", "limit", "stop"]
          validation_criteria = ["routing", "execution", "confirmation"]
        },
        database_sync = {
          sync_points       = ["trades", "positions", "orders"]
          consistency_check = "true"
        }
      })
    }
  }
}

# DR Test Monitoring
resource "aws_cloudwatch_metric_alarm" "dr_test_failure" {
  alarm_name          = "${local.name}-dr-test-failure"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "TestFailureCount"
  namespace           = "Custom/DRTests"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "DR test failure detected"
  alarm_actions       = [aws_sns_topic.dr_alerts.arn]
}

# infrastructure/modules/networking/dr_testing_advanced.tf

# Advanced DR Test State Machine
resource "aws_sfn_state_machine" "dr_advanced_testing" {
  name     = "${local.name}-dr-advanced-testing"
  role_arn = aws_iam_role.dr_testing.arn

  definition = jsonencode({
    StartAt = "InitializeTestEnvironment"
    States = {
      InitializeTestEnvironment = {
        Type = "Task"
        Resource = aws_lambda_function.init_test_env.arn
        Next = "SelectTestScenario"
      },

      SelectTestScenario = {
        Type = "Choice"
        Choices = [
          {
            Variable = "$.testType"
            StringEquals = "MULTI_REGION_MARKET_DATA"
            Next = "TestMultiRegionMarketData"
          },
          {
            Variable = "$.testType"
            StringEquals = "PARTIAL_SYSTEM_FAILURE"
            Next = "TestPartialSystemFailure"
          },
          {
            Variable = "$.testType"
            StringEquals = "QUOTE_SYSTEM_FAILURE"
            Next = "TestQuoteSystemFailure"
          },
          {
            Variable = "$.testType"
            StringEquals = "TRADING_ENGINE_FAILOVER"
            Next = "TestTradingEngineFailover"
          }
        ]
      },

      TestMultiRegionMarketData = {
        Type = "Parallel"
        Branches = [
          {
            StartAt = "SimulateRegionalOutage"
            States = {
              SimulateRegionalOutage = {
                Type = "Task"
                Resource = aws_lambda_function.simulate_regional_outage.arn
                Next = "ValidateDataConsistency"
              },
              ValidateDataConsistency = {
                Type = "Task"
                Resource = aws_lambda_function.validate_market_data.arn
                End = true
              }
            }
          }
        ],
        Next = "ValidateFailoverSuccess"
      },

      TestPartialSystemFailure = {
        Type = "Parallel"
        Branches = [
          {
            StartAt = "SimulatePartialFailure"
            States = {
              SimulatePartialFailure = {
                Type = "Task"
                Resource = aws_lambda_function.simulate_partial_failure.arn
                Next = "ValidateIsolation"
              },
              ValidateIsolation = {
                Type = "Task"
                Resource = aws_lambda_function.validate_system_isolation.arn
                Next = "VerifyOtherSystems"
              },
              VerifyOtherSystems = {
                Type = "Task"
                Resource = aws_lambda_function.verify_healthy_systems.arn
                End = true
              }
            }
          }
        ],
        Next = "ValidateFailoverSuccess"
      },

      TestTradingEngineFailover = {
        Type = "Parallel"
        Branches = [
          {
            StartAt = "PrepareInflightOrders"
            States = {
              PrepareInflightOrders = {
                Type = "Task"
                Resource = aws_lambda_function.prepare_inflight_orders.arn
                Next = "SimulateEngineFailure"
              },
              SimulateEngineFailure = {
                Type = "Task"
                Resource = aws_lambda_function.simulate_engine_failure.arn
                Next = "ValidateOrderStatus"
              },
              ValidateOrderStatus = {
                Type = "Task"
                Resource = aws_lambda_function.validate_orders.arn
                End = true
              }
            }
          }
        ],
        Next = "ValidateFailoverSuccess"
      },

      ValidateFailoverSuccess = {
        Type = "Task"
        Resource = aws_lambda_function.validate_failover.arn
        Next = "GenerateTestReport"
      },

      GenerateTestReport = {
        Type = "Task"
        Resource = aws_lambda_function.generate_test_report.arn
        End = true
      }
    }
  })
}

# Test Result Validation
resource "aws_lambda_function" "validate_test_results" {
  filename      = "validate_test_results.zip"
  function_name = "${local.name}-validate-test-results"
  role         = aws_iam_role.dr_test.arn
  handler      = "index.handler"
  runtime      = "nodejs16.x"
  timeout      = 300

  environment {
    variables = {
      VALIDATION_CRITERIA = jsonencode({
        market_data = {
          max_data_loss_seconds = "5",
          consistency_threshold = "99.99",
          required_feeds = ["level1", "level2", "trades"]