terraform {
  required_providers {
    talos = {
      source = "siderolabs/talos"
      version = "0.2.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.20.0"
    }
  }
}

provider "talos" {
  # Configuration options
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "this" {
  cluster_name     = "talos-cube"
  machine_type     = "controlplane"
  cluster_endpoint = "https://192.168.1.11:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}


provider "kubernetes" {
  host = "https://192.168.1.11:6443"
  config_path = "~/.kube/config"
}

