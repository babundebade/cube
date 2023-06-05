resource "kubernetes_manifest" "namespace_ingress_nginx" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = "nginx-ingress"
    }
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "nginx-ingress"
  namespace  = "nginx-ingress"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  #version    = "0.17.1"

  values = [file("services/ingress-nginx/values.yaml")]

  depends_on = [kubernetes_manifest.namespace_ingress_nginx]
}
