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
    ingress_hosts               = var.URL_pihole
    serviceDNS_loadBalancerIPv4 = var.dns_IPv4
    pihole_web_url              = var.URL_pihole
    pihole_web_ip               = "192.168.1.129"
  })]

  depends_on = [kubernetes_manifest.namespace_pihole, helm_release.ingress_nginx]
}

variable "pihole_cert_name" {
  type        = string
  default     = "pihole-crt"
  description = "name of certificate"
}

variable "pihole_secret_name" {
  type        = string
  default     = "pihole-scrt"
  description = "name of secret"
}

resource "terraform_data" "pihole_ingress" {
  input = var.URL_pihole
}

resource "terraform_data" "pihole_cert_name" {
  input = var.pihole_cert_name
}

resource "terraform_data" "pihole_secret_name" {
  input = var.pihole_secret_name
}

resource "null_resource" "pihole_cert" {
  provisioner "local-exec" {
    command = "envsubst < ${path.module}/services/pihole/pihole-cert.yaml | kubectl apply -f -"

    environment = {
      PIHOLE_CERT_NAME   = var.pihole_cert_name
      PIHOLE_SECRET_NAME = var.pihole_secret_name
      URL_PIHOLE         = var.URL_pihole
    }
  }
  depends_on = [helm_release.cert-manager]
  lifecycle {
    replace_triggered_by = [terraform_data.pihole_cert_name, terraform_data.pihole_secret_name]
  }
}

resource "null_resource" "pihole_ingress" {
  provisioner "local-exec" {
    command = "envsubst < ${path.module}/services/pihole/pihole-ingress.yaml | kubectl apply -f -"

    environment = {
      PIHOLE_SECRET_NAME = var.pihole_secret_name
      URL_PIHOLE         = var.URL_pihole
    }
  }
  depends_on = [helm_release.cert-manager]
  lifecycle {
    replace_triggered_by = [terraform_data.pihole_ingress, terraform_data.pihole_secret_name]
  }
}
