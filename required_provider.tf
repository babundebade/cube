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

    helm = {
      source = "hashicorp/helm"
      version = "2.9.0"
    }
  }
}