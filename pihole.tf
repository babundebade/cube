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

  values = [templatefile("${path.module}/services/pihole/values-pihole.yaml", {
    PIHOLE_DNS_IP = var.dns_IPv4
    PIHOLE_WEB_IP = var.ip_pool_start
    PIHOLE_CNAME  = var.pihole_cname
    TLD_DOMAIN    = var.tld_domain
  })]

  depends_on = [kubernetes_manifest.namespace_pihole, helm_release.ingress_nginx]
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

resource "terraform_data" "pihole_ingress" {
  input = var.pihole_cname
}

resource "terraform_data" "pihole_cert_name" {
  input = var.pihole_cert_name
}

resource "terraform_data" "pihole_secret_name" {
  input = var.pihole_secret_name
}

resource "null_resource" "pihole_ingress" {
  provisioner "local-exec" {
    command = "envsubst < ${path.module}/services/pihole/pihole-ingress.yaml | kubectl apply -f -"

    environment = {
      CERT_MANAGER_NAME  = var.cert_manager_name
      PIHOLE_SECRET_NAME = var.pihole_secret_name
      PIHOLE_CNAME  = var.pihole_cname
    }
  }
  #depends_on = [null_resource.pihole_cert]
  lifecycle {
    replace_triggered_by = [terraform_data.pihole_ingress, terraform_data.pihole_secret_name]
  }
}
