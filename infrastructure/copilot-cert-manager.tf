# resource "kubernetes_namespace" "namespace_cert_manager" {
#   metadata {
#     name = "cert-manager"
#   }
# }

# resource "helm_release" "cert-manager" {
#   name       = "cert-manager"
#   namespace  = kubernetes_namespace.namespace_cert_manager.metadata[0].name
#   repository = "https://charts.jetstack.io"
#   chart      = "cert-manager" #jetstack/cert-manager

#   values = [file("${path.module}/services/cert-manager/values.yaml")]

#   depends_on = [kubernetes_namespace.namespace_cert_manager, helm_release.metallb]
# }

# resource "kubernetes_secret" "root_cert" {
#   metadata {
#     name      = "root-ca"
#     namespace = kubernetes_namespace.namespace_cert_manager.metadata[0].name
#   }

#   #   data = {
#   #     "tls.crt" = "${base64encode(file("${path.module}/services/cert-manager/root-ca.crt"))}"
#   #   }

#   type = "kubernetes.io/tls"
# }

# resource "kubernetes_manifest" "root_cert_issuer" {
#   manifest = jsonencode({
#     apiVersion = "cert-manager.io/v1"
#     kind       = "Issuer"
#     metadata = {
#       name = "root-ca-issuer"
#     }
#     spec = {
#       selfSigned = {}
#     }
#   })

#   depends_on = [kubernetes_secret.root_cert]
# }

# resource "kubernetes_manifest" "root_cert" {
#   manifest = jsonencode({
#     apiVersion = "cert-manager.io/v1"
#     kind       = "Certificate"
#     metadata = {
#       name      = "root-ca"
#       namespace = kubernetes_namespace.namespace_cert_manager.metadata[0].name
#     }
#     spec = {
#       isCA       = true
#       commonName = "root-ca"
#       secretName = kubernetes_secret.root_cert.metadata[0].name
#       issuerRef = {
#         name = kubernetes_manifest.root_cert_issuer.metadata[0].name
#       }
#     }
#   })

#   depends_on = [kubernetes_manifest.root_cert_issuer]
# }

# resource "kubernetes_manifest" "cert_issuer" {
#   manifest = jsonencode({
#     apiVersion = "cert-manager.io/v1"
#     kind       = "ClusterIssuer"
#     metadata = {
#       name = "selfsigned"
#     }
#     spec = {
#       selfSigned = {}
#     }
#   })

#   depends_on = [kubernetes_manifest.root_cert]
# }

# resource "kubernetes_manifest" "pihole_cert" {
#   manifest = jsonencode({
#     apiVersion = "cert-manager.io/v1"
#     kind       = "Certificate"
#     metadata = {
#       name      = "pihole-cert"
#       namespace = "pihole"
#     }
#     spec = {
#       secretName = "pihole-tls"
#       issuerRef = {
#         name = "selfsigned"
#         kind = "ClusterIssuer"
#       }
#       commonName = "${var.domain_name}"
#       dnsNames = [
#         "${var.domain_name}"
#       ]
#     }
#   })

#   depends_on = [kubernetes_manifest.cert_issuer]
# }
