variable "cluster_name" {
  type = string
  description = "value of cluster_name"
  default = "talos-cube"
}

variable "cluster_kubeconfig_path" {
    type = string
    default = "/home/dario/cube/.talos/configs/kubeconfig"
    description = "Location of kubeconfig file"
}

variable "dns_IPv4" {
  type = string
  default = "192.168.1.130"
  description = "IP address of DNS server (Pihole-DNS-Service)"
}

variable "ip_pool_start" {
  type = string
  default = "192.168.1.129"
  description = "start of IP pool"  
}

variable "ip_pool_end" {
  type = string
  default = "192.168.1.135"
  description = "end of IP pool"
}