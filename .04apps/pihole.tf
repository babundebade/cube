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

resource "kubernetes_persistent_volume_claim_v1" "pihole_pvc" {
  metadata {
    name      = "pihole-pvc"
    namespace = kubernetes_namespace.pihole_namespace.metadata[0].name
  }
  spec {
    storage_class_name = var.storage_class_name
    access_modes       = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "helm_release" "pihole" {
  name       = "pihole"
  namespace  = kubernetes_namespace.pihole_namespace.metadata[0].name
  repository = "https://mojo2600.github.io/pihole-kubernetes/"
  chart      = "pihole" #mojo2600/pihole

  values = [templatefile("${path.module}/services/pihole/values-pihole.yaml", {
    PIHOLE_DNS_IP = var.dns_IPv4
    PIHOLE_WEB_IP = var.ip_pool_start
    PIHOLE_CNAME  = var.tld_domain
    PIHOLE_PVC    = var.pihole_pvc_name
    STORAGE_CLASS_NAME = var.storage_class_name
  })]

  depends_on = [kubernetes_namespace.pihole_namespace]
}

resource "kubernetes_ingress_v1" "pihole_ingress" {
  metadata {
    name      = "pihole-ingress"
    namespace = kubernetes_namespace.pihole_namespace.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer" = var.cert_issuer_name
    }
  }

  spec {
    ingress_class_name = "nginx"
    tls {
      hosts       = [var.tld_domain]
      secret_name = var.pihole_secret_name
    }
    rule {
      host = var.tld_domain
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
  #depends_on = [ helm_release.ingress_nginx, helm_release.cert-manager ]
}
