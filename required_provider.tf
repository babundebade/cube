terraform {
  required_providers {
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