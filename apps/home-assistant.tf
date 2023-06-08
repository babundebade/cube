resource "kubernetes_namespace" "home_assistant_namespace" {
  metadata {
    name = "home-assistant"
  }
}

resource "null_resource" "kubeconfig_home_assistant" {
  provisioner "local-exec" {
    command = "kubectl label ns home-assistant pod-security.kubernetes.io/enforce=privileged"
  }
  depends_on = [kubernetes_namespace.home_assistant_namespace]
}

resource "helm_release" "home_assistant" {
  name       = "home-assistant"
  namespace  = "home-assistant"
  repository = "https://charts.alekc.dev"
  chart      = "home-assistant"
  #version    = "2023.5.3"

  values     = [file("services/home-assistant/values.yaml")]
  depends_on = [kubernetes_namespace.home_assistant_namespace, null_resource.kubeconfig_home_assistant]
}

# resource "null_resource" "ha_ingress" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f services/home-assistant/ha-ingress.yaml"
#   }
#   depends_on = [helm_release.home_assistant]
# }