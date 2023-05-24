resource "kubernetes_manifest" "namespace_metallb_system" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Namespace"
    "metadata" = {
      "labels" = {
        "app" = "metallb"
      }
      "name" = "metallb-system"
    }
  }
}

resource "kubernetes_manifest" "l2advertisement_metallb_system_metallb_l2advertisment" {
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind" = "L2Advertisement"
    "metadata" = {
      "name" = "metallb-L2Advertisment"
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
        "192.168.10.0/24",
      ]
    }
  }
}

resource "kubernetes_manifest" "role_metallb_system_secret_reader" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "name" = "secret-reader"
      "namespace" = "metallb-system"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "secrets",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "rolebinding_metallb_system_secret_reader_binding" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "name" = "secret-reader-binding"
      "namespace" = "metallb-system"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "Role"
      "name" = "secret-reader"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "metallb-controller"
        "namespace" = "metallb-system"
      },
    ]
  }
}
