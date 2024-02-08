resource "kubernetes_namespace" "namespace_ingress_nginx" {
  metadata {
    name = "nginx-ingress"
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "nginx-ingress"
  namespace  = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx" #"https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx" #"ingress-nginx"
  version    = var.version_nginx_ingress

  #values = [file("services/ingress-nginx/values.yaml")]

  depends_on = [kubernetes_namespace.namespace_ingress_nginx]
}
