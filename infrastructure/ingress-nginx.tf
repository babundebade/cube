resource "kubernetes_namespace" "namespace_ingress_nginx" {
  metadata {
    name = "nginx-ingress"
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "nginx-ingress"
  namespace  = "nginx-ingress"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  #version    = "0.17.1"

  values = [file("services/ingress-nginx/values.yaml")]

  depends_on = [kubernetes_namespace.namespace_ingress_nginx, helm_release.metallb]
}
