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

resource "null_resource" "home_assistant_ingress" {
  provisioner "local-exec" {
    command = "envsubst < ${path.module}/services/home-assistant/ha-ingress.yaml | kubectl apply -f -"
  }
  depends_on = [helm_release.home_assistant]
}

resource "kubernetes_persistent_volume_claim" "ha_pvc" {
  metadata {
    name      = "home-assistant-pvc"
    namespace = kubernetes_namespace.home_assistant_namespace.metadata[0].name
  }

  spec {
    storage_class_name = "openebs-jiva-csi-default"
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
  depends_on = [helm_release.home_assistant]
}