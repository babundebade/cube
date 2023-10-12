variable "cluster_name" {
  description = "value of cluster_name"
  type        = string
  default     = "talos-cube"
}

variable "cluster_endpoint" {
  description = "The endpoint for the Talos cluster"
  type        = string
  default     = "https://192.168.1.10:6443"
}

variable "talos_version" {
  description = "The version of Talos to use"
  type        = string
  default     = "v1.5.3"
}

variable "kubernetes_version" {
  description = "The version of Kubernetes to use"
  type        = string
  default     = "v1.28.2"
}

variable "node_data" {
  description = "A map of node data"
  type = object({
    controlplanes = map(object({
      install_disk = string
      hostname     = optional(string)
    }))
    workers = map(object({
      install_disk = string
      hostname     = optional(string)
    }))
  })
  default = {
    controlplanes = {
      "192.168.1.10" = {
        install_disk = "/dev/sda"
        hostname     = "controlplane-10"
      },
      # "192.168.1.11" = {
      #   install_disk = "/dev/sda"
      #   hostname     = "controlplane-11"
      # },
      # "192.168.1.12" = {
      #   install_disk = "/dev/sda"
      #   hostname     = "controlplane-12"
      # },
    },
    workers = {
      "192.168.1.11" = {
        install_disk = "/dev/sda"
        hostname     = "worker-11"
      },
      "192.168.1.12" = {
        install_disk = "/dev/sda"
        hostname     = "worker-12"
      }
    }
  }
}
