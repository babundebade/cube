resource "kubernetes_manifest" "l2advertisement_metallb_system_metallb_l2advertisment" {
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind" = "L2Advertisement"
    "metadata" = {
      "name" = "metallb-l2advertisment"
      "namespace" = "metallb-system"
    }
    "spec" = {
      "ipAddressPools" = [
        "metallb-pool",
      ]
    }
  }
}

resource "kubernetes_manifest" "ipaddresspool_metallb_system_metallb_pool" {
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind" = "IPAddressPool"
    "metadata" = {
      "name" = "metallb-pool"
      "namespace" = "metallb-system"
    }
    "spec" = {
      "addresses" = [
        "$${ip_pool_start} - $${ip_pool_end}",
      ]
    }
  }
}
