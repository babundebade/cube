resource "kubernetes_manifest" "home-assistant-namespace" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = "home-assistant"
    }
  }
}

resource "null_resource" "kubeconfig_home-assistant" {
  provisioner "local-exec" {
    command = "kubectl label ns home-assistant pod-security.kubernetes.io/enforce=privileged"
  }
  depends_on = [kubernetes_manifest.home-assistant-namespace]
}

resource "helm_release" "home-assistant" {
  name       = "home-assistant"
  namespace  = "home-assistant"
  repository = "https://geek-cookbook.github.io/charts/"
  chart      = "home-assistant"

  values = [file("modules/home-assistant/values.yaml")]
}

resource "null_resource" "home-assistant-resources" {
  provisioner "local-exec" {
    command = "kubectl apply -f modules/home-assistant/ha-ingress.yaml"
  }
  depends_on = [helm_release.home-assistant]
}