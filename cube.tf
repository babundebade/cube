provider "talos" {
  # Configuration options
}

resource "talos_machine_secrets" "controller" {}

data "talos_machine_configuration" "controller" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = "https://192.168.1.11:6443"
  machine_secrets  = talos_machine_secrets.controller.machine_secrets
}

data "talos_client_configuration" "controller" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.controller.client_configuration
  nodes                = ["192.168.1.11"]
}

/* resource "talos_machine_configuration_apply" "controller" {
  client_configuration        = talos_machine_secrets.controller.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controller.machine_configuration
  node                        = "192.168.1.11"
} */

provider "kubernetes" {
  host        = "https://192.168.1.11:6443"
  config_path = var.cluster_kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.cluster_kubeconfig_path
  }
}

resource "kubernetes_manifest" "namespace_metallb_system" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = "metallb-system"
    }
  }
}

resource "null_resource" "kubeconfig_metallb" {
  provisioner "local-exec" {
    command = "kubectl label ns metallb-system pod-security.kubernetes.io/enforce=privileged"
  }
  depends_on = [kubernetes_manifest.namespace_metallb_system]
}

resource "helm_release" "metallb" {
  name       = "metallb"
  namespace  = "metallb-system"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metallb"
  #version    = "0.13.9"

  values = [file("modules/metallb/values.yaml")]

  #depends_on = [null_resource.kubeconfig_metallb]
}

/* resource "kubernetes_manifest" "ipaddresspool_metallb_system_metallb_pool" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    "metadata" = {
      "name"      = "metallb-pool"
      "namespace" = "metallb-system"
    }
    "spec" = {
      "addresses" = [
        "192.168.1.130 - 192.168.1.140",
      ]
    }
  }
  #depends_on = [helm_release.metallb]
}

resource "kubernetes_manifest" "l2advertisement_metallb_system_metallb_l2advertisment" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"
    "metadata" = {
      "name"      = "metallb-l2advertisment"
      "namespace" = "metallb-system"
    }
  }
  #depends_on = [helm_release.metallb]
} */

resource "null_resource" "metallb-resources" {
  provisioner "local-exec" {
    command = "kubectl apply -f modules/metallb/configmap.yaml"
  }
  depends_on = [helm_release.metallb]
}

/* resource "null_resource" "pihole" {
  provisioner "local-exec" {
    command = "kubectl apply -f modules/pihole/pihole-svc.yaml"
  }
} */

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

  values = [file("modules/pihole/values-pihole.yaml")]

  depends_on = [kubernetes_manifest.namespace_pihole]  
}