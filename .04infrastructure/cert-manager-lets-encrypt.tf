# resource "kubernetes_manifest" "letsencrypt_staging_issuer" {
#   manifest = {
#     apiVersion = "cert-manager.io/v1"
#     kind       = "ClusterIssuer"
#     metadata = {
#       name = var.cert_issuer_name #"letsencrypt-staging"
#     }
#     spec = {
#       acme = {
#         email  = var.email
#         server = "https://acme-staging-v02.api.letsencrypt.org/directory"
#         privateKeySecretRef = {
#           name = "letsencrypt-staging"
#         }
#         solvers = [
#           {
#             http01 = {
#               ingress = {
#                 class = "nginx"
#               }
#             }
#           }
#         ]
#       }
#     }
#   }
# }

# resource "kubernetes_manifest" "letsencrypt_production_issuer" {
#   manifest = {
#     apiVersion = "cert-manager.io/v1"
#     kind       = "ClusterIssuer"
#     metadata = {
#       name = "letsencrypt-production"
#     }
#     spec = {
#       acme = {
#         email  = var.email
#         server = "https://acme-v02.api.letsencrypt.org/directory"
#         privateKeySecretRef = {
#           name = "letsencrypt-production"
#         }
#         solvers = [
#           {
#             http01 = {
#               ingress = {
#                 class = "nginx"
#               }
#             }
#           }
#         ]
#       }
#     }
#   }
# }
