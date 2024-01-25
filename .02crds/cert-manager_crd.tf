resource "kubernetes_namespace" "namespace_cert_manager" {
  metadata {
    name = var.namespace_cert_manager
  }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace.namespace_cert_manager.metadata[0].name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.version_cert_manager

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