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
    ingress_hosts = var.URL_pihole
    serviceDNS_loadBalancerIPv4 = var.dns_IPv4
    pihole_web_url = var.URL_pihole
    pihole_web_ip = "192.168.1.129"
  })]

  depends_on = [kubernetes_manifest.namespace_pihole, helm_release.ingress_nginx]
}

resource "null_resource" "pihole_ingress" {
  provisioner "local-exec" {
    command = "envsubst < ${path.module}/services/pihole/pihole-ingress.yaml | kubectl apply -f -"

    environment = {
      URL_PIHOLE = var.URL_pihole
    }
  }
  depends_on = [helm_release.cert-manager]
}
