resource "kubernetes_manifest" "home_assistant_namespace" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = "home-assistant"
    }
  }
}

resource "null_resource" "kubeconfig_home_assistant" {
  provisioner "local-exec" {
    command = "kubectl label ns home-assistant pod-security.kubernetes.io/enforce=privileged"
  }
  depends_on = [kubernetes_manifest.home_assistant_namespace]
}

########################################################### BROKEN ###########################################################
/* resource "helm_release" "home_assistant" {
  name       = "home-assistant"
  namespace  = "home-assistant"
  repository = "https://loeken.github.io/helm-charts"
  chart      = "home-assistant"
  version    = "2023.5.3"

  values     = [file("services/home-assistant/values.yaml")]
  depends_on = [kubernetes_manifest.home_assistant_namespace]
} */

/* resource "null_resource" "home-assistant-resources" {
  provisioner "local-exec" {
    command = "kubectl apply -f services/home-assistant/ha-ingress.yaml"
  }
  depends_on = [helm_release.home-assistant]
} */

/* module "ingress" {
  source  = "terraform-iaac/ingress/kubernetes"
  version = "2.0.1"

  service_name = "home-assistant"
  service_namespace = "home-assistant"
  annotations = {
    "app" = "home-assistant"
  }

  rule = [
    {
      domain = "home-assistant.local"
      external_port = 8123
    }
  ]
  depends_on = [ kubernetes_manifest.home_assistant_namespace ]
} */

# resource "kubernetes_ingress_v1" "ingress_home_assistant" {
#   metadata {
#     name      = "home-assistant"
#     namespace = "home-assistant"
#     labels = {
#       "app" = "home-assistant"
#     }
#   }
#   spec {
#     ingress_class_name = "nginx"
#     rule {
#       host = "home-assistant.local"
#       http {
#         path {
#           #          path = "/"
#           backend {
#             service {
#               name = "home-assistant"
#               port {
#                 number = 80
#               }
#             }
#           }
#         }
#       }
#     }
#   }
# }
