resource "kubernetes_manifest" "ipaddresspool_metallb_pool" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = "metallb_ip_pool"
      namespace = "metallb-system"
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
      namespace = "metallb-system"
    }
    spec = {
      ipAddressPools = [
        kubernetes_manifest.ipaddresspool_metallb_pool.manifest.metadata[0].name
      ]
    }
  }
}
