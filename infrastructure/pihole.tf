resource "kubernetes_namespace" "pihole_namespace" {
  metadata {
    name = "pihole"
  }
}

resource "null_resource" "kubeconfig_pihole" {
  provisioner "local-exec" {
    command = "kubectl label ns pihole pod-security.kubernetes.io/enforce=privileged"
  }
  depends_on = [kubernetes_namespace.pihole_namespace]
}

resource "helm_release" "pihole" {
  name       = "pihole"
  namespace  = kubernetes_namespace.pihole_namespace.metadata[0].name
  repository = "https://mojo2600.github.io/pihole-kubernetes/"
  chart      = "pihole" #mojo2600/pihole

  values = [templatefile("${path.module}/services/pihole/values-pihole.yaml", {
    PIHOLE_DNS_IP = var.dns_IPv4
    PIHOLE_WEB_IP = var.ip_pool_start
    PIHOLE_CNAME  = var.pihole_cname
    TLD_DOMAIN    = var.tld_domain
  })]

  depends_on = [helm_release.ingress_nginx, helm_release.cert-manager]
}

variable "pihole_cert_name" {
  type        = string
  default     = "pihole"
  description = "name of certificate"
}

variable "pihole_secret_name" {
  type        = string
  default     = "pihole"
  description = "name of secret"
}

resource "terraform_data" "pihole_cname" {
  input = var.pihole_cname
}

# resource "terraform_data" "pihole_cert_name" {
#   input = var.pihole_cert_name
# }

resource "terraform_data" "pihole_secret_name" {
  input = var.pihole_secret_name
}

resource "kubernetes_ingress_v1" "pihole_ingress" {
  metadata {
    name      = "pihole-ingress"
    namespace = kubernetes_namespace.pihole_namespace.metadata[0].name
    annotations = {
      #"kubernetes.io/ingress.class" = "nginx"
      "cert-manager.io/cluster-issuer" = "cert-issuer"
      #"nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"
    tls {
      hosts = [var.pihole_cname]
      secret_name = terraform_data.pihole_secret_name.input
    }
    rule {
      host = var.pihole_cname
      http {
        path {
          path = "/admin"
          backend {
            service {
              name = "pihole-web"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
  depends_on = [ helm_release.ingress_nginx, helm_release.cert-manager ]
}

# resource "null_resource" "pihole_ingress" {
#   provisioner "local-exec" {
#     command = "envsubst < ${path.module}/services/pihole/pihole-ingress.yaml | kubectl apply -f -"

#     environment = {
#       CERT_MANAGER_NAME  = var.cert_manager_name
#       PIHOLE_SECRET_NAME = var.pihole_secret_name
#       PIHOLE_CNAME  = var.pihole_cname
#     }
#   }
#   #depends_on = [null_resource.pihole_cert]
#   lifecycle {
#     replace_triggered_by = [terraform_data.pihole_ingress, terraform_data.pihole_secret_name]
#   }
# }

# resource "null_resource" "pihole_cert" {
#   provisioner "local-exec" {
#     command = "envsubst < ${path.module}/services/pihole/pihole-cert.yaml | kubectl apply -f -"

#     environment = {
#       EMAIL = var.email
#       CERT_MANAGER_NAME = var.cert_manager_name
#       CERT_MANAGER_NAMESPACE = resource.kubernetes_namespace.namespace_cert_manager.metadata[0].name
#       PIHOLE_SECRET_NAME = var.pihole_secret_name
#     }
#   }
    
#   lifecycle {
#     replace_triggered_by = [terraform_data.cert-manager_email, terraform_data.cert-manager_name]
#   }

#   depends_on = [null_resource.root_issuer, resource.kubernetes_namespace.namespace_cert_manager]
# }