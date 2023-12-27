resource "kubernetes_namespace" "metallb_namespace" {
  metadata {
    name = "metallb-system"
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  namespace  = kubernetes_namespace.metallb_namespace.metadata[0].name
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb/metallb"

  #values = [file("services/metallb/values.yaml")]
}

resource "kubernetes_manifest" "ipaddresspool_metallb_pool" {
  depends_on = [helm_release.metallb]
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = "metallb_ip_pool"
      namespace = kubernetes_namespace.metallb_namespace.metadata[0].name
    }
    spec = {
      addresses = [
        "192.168.1.129 - 192.168.1.135"
      ]
    }
  }
}

resource "kubernetes_manifest" "l2advertisement_metallb" {
  depends_on = [helm_release.metallb]
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"
    metadata = {
      name      = "metallb-l2advertisment"
      namespace = kubernetes_namespace.metallb_namespace.metadata[0].name
    }
    spec = {
      ipAddressPools = [
        kubernetes_manifest.ipaddresspool_metallb_pool.manifest.metadata[0].name
      ]
    }
  }
}
