provider "kubernetes" {
  host        = "https://192.168.1.10:6443"
  config_path = var.cluster_kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.cluster_kubeconfig_path
  }
}

