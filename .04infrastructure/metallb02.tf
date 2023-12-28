resource "kubernetes_manifest" "ipaddresspool_metallb_pool" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = "metallb-ip-pool"
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
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"
    metadata = {
      name      = "metallb-l2advertisment"
      namespace = "metallb-system"
    }
    spec = {
      ipAddressPools = ["metallb-ip-pool"]
    }
  }
}
