resource "kubernetes_manifest" "namespace_cert_manager" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = "cert-manager"
    }
  }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager" #jetstack/cert-manager

  values = [file("${path.module}/services/cert-manager/values.yaml")]

  depends_on = [kubernetes_manifest.namespace_cert_manager, helm_release.metallb]
}

resource "null_resource" "cert-manager_issuer" {
  provisioner "local-exec" {
    command = "envsubst < ${path.module}/services/cert-manager/issuer.yaml | kubectl apply -f -"

    environment = {
      EMAIL = var.email
    }
  }
  depends_on = [helm_release.cert-manager]
}
