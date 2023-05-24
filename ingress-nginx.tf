resource "kubernetes_manifest" "ingress-nginx" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = "ingress-nginx"
    }
  }
}

resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  values = [file("services/ingress-nginx/ingress-nginx_values.yaml")]

  depends_on = [kubernetes_manifest.ingress-nginx]
}