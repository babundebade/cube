variable "cluster_name" {
  type = string
  description = "value of cluster_name"
  default = "talos-cube"
}

variable "cluster_kubeconfig_path" {
    type = string
    default = "~/cube/kubeconfig_cube"
    description = "Location of kubeconfig file"
}

