# # modules/eks/scaling_rules.tf

# resource "kubernetes_horizontal_pod_autoscaler" "arbiters" {
#   metadata {
#     name      = "arbiters-hpa"
#     namespace = "trading"
#   }

#   spec {
#     max_replicas = 10
#     min_replicas = 2

#     target_cpu_utilization_percentage = 70

#     scale_target_ref {
#       api_version = "apps/v1"
#       kind        = "Deployment"
#       name        = "arbiters"
#     }

#     metric {
#       type = "External"
#       external {
#         metric {
#           name = "orders_per_second"
#           selector {
#             match_labels = {
#               service = "arbiters"
#             }
#           }
#         }
#         target {
#           type  = "AverageValue"
#           value = "1000"
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_horizontal_pod_autoscaler" "market_data" {
#   metadata {
#     name      = "market-data-hpa"
#     namespace = "trading"
#   }

#   spec {
#     max_replicas = 8
#     min_replicas = 2

#     metric {
#       type = "Resource"
#       resource {
#         name = "memory"
#         target {
#           type                = "Utilization"
#           average_utilization = 75
#         }
#       }
#     }

#     scale_target_ref {
#       api_version = "apps/v1"
#       kind        = "Deployment"
#       name        = "market-data"
#     }
#   }
# }
