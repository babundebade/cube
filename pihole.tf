resource "kubernetes_manifest" "namespace_pihole" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = "pihole"
    }
  }
}

resource "null_resource" "kubeconfig_pihole" {
  provisioner "local-exec" {
    command = "kubectl label ns pihole pod-security.kubernetes.io/enforce=privileged"
  }
  depends_on = [kubernetes_manifest.namespace_pihole]
}

resource "helm_release" "pihole" {
  name       = "pihole"
  namespace  = "pihole"
  repository = "https://mojo2600.github.io/pihole-kubernetes/"
  chart      = "pihole" #mojo2600/pihole

  values = [templatefile("${path.module}/services/pihole/values-pihole.yaml.tmpl", {
    ingress_hosts = "pi.cool"
    serviceDNS_loadBalancerIPv4 = var.dns_IPv4
    pihole_web_url = "pi.cool"
    pihole_web_ip = "192.168.1.129"
  })]

  depends_on = [kubernetes_manifest.namespace_pihole]
}

# resource "kubernetes_ingress_v1" "pihole_web_ingress" {
#   metadata {
#     name = "pihole-web"
#     namespace = "pihole"
#   }

#   spec {
#     rule {
#       host = "pihole.local"
#       http {
#         path {
#           backend {
#             serviceName = "pihole-web"
#             servicePort = 80
#           }
#         }
#       }
#     }
#   }

#   depends_on = [helm_release.pihole]
# }
