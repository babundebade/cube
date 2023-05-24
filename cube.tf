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

