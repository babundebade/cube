resource "kubernetes_namespace" "namespace_cert_manager" {
  metadata {
    name = var.namespace_cert_manager
  }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  namespace  = var.namespace_cert_manager
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.5.3"

  #values = [file("${path.module}/services/cert-manager/values.yaml")]
  set {
    name  = "installCRDs"
    value = "true"
  }
  set {
    name  = "prometheus.enabled"
    value = "false"
  }
  depends_on = [kubernetes_namespace.namespace_cert_manager]
}