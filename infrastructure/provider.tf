terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
      # https://registry.terraform.io/providers/hashicorp/kubernetes/latest
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
      # https://registry.terraform.io/providers/hashicorp/helm/latest
    }

    mikrotik = {
      source  = "kube-cloud/mikrotik"
      version = "0.13.0"
      # https://registry.terraform.io/providers/kube-cloud/mikrotik/latest
    }
  }
}

provider "kubernetes" {
  host        = "https://192.168.1.10:6443"
  config_path = pathexpand("~/.kube/config") #var.cluster_kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/config") #var.cluster_kubeconfig_path
  }
}