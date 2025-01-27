# modules/eks/network_policies.tf

# resource "kubernetes_network_policy" "arbiters" {
#   metadata {
#     name      = "arbiter-network-policy"
#     namespace = "trading"
#   }

#   spec {
#     pod_selector {
#       match_labels = {
#         role = "arbiter"
#       }
#     }

#     ingress {
#       from {
#         pod_selector {
#           match_labels = {
#             role = "api"
#           }
#         }
#       }
#       ports {
#         port     = "8080"
#         protocol = "TCP"
#       }
#     }

#     egress {
#       to {
#         pod_selector {
#           match_labels = {
#             role = "executor"
#           }
#         }
#       }
#       ports {
#         port     = "8080"
#         protocol = "TCP"
#       }
#     }

#     policy_types = ["Ingress", "Egress"]
#   }
# }

# resource "kubernetes_network_policy" "market_data" {
#   metadata {
#     name      = "market-data-network-policy"
#     namespace = "trading"
#   }

#   spec {
#     pod_selector {
#       match_labels = {
#         role = "market-data"
#       }
#     }

#     ingress {
#       from {
#         namespace_selector {
#           match_labels = {
#             name = "trading"
#           }
#         }
#       }
#       ports {
#         port     = "8081"
#         protocol = "TCP"
#       }
#     }

#     policy_types = ["Ingress"]
#   }
# }
