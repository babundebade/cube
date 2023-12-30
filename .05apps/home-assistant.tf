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
  repository = "https://charts.alekc.dev/"
  chart      = "home-assistant"
  version    = "latest"

  set {
    name = "nodeSelector.kubernetes\\.io/hostname"
    value = "cntrlpln-13-blue"
  }
  set {
    name = "persistence.enabled"
    value = false
  }
  # set {
  #   name = "persistence.storageClass"
  #   value = var.storage_class_name
  # }
  # set {
  #   name = "persistence.existingClaim"
  #   value = kubernetes_persistent_volume_claim.ha_pvc.metadata[0].name
  # }
  #values     = [file("services/home-assistant/values.yaml")]
  depends_on = [kubernetes_namespace.home_assistant_namespace, null_resource.kubeconfig_home_assistant]
}

resource "kubernetes_ingress_v1" "ha_ingress" {
  metadata {
    name      = "home-assistant-ingress"
    namespace = kubernetes_namespace.home_assistant_namespace.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer" = var.cert_issuer_name
    }
  }

  spec {
    ingress_class_name = "nginx"
    tls {
      hosts = ["ha.darioludwig.space", "192.168.1.131"]
      secret_name = "ha-secret"
    }
    rule {
      host = "ha.darioludwig.space"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "home-assistant"
              port {
                number = 8123
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "ha_pvc" {
  metadata {
    name      = "home-assistant-pvc"
    namespace = kubernetes_namespace.home_assistant_namespace.metadata[0].name
  }

  spec {
    storage_class_name = var.storage_class_name
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
  
}