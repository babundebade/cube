variable "cluster_name" {
  type        = string
  description = "value of cluster_name"
  default     = "talos-cube"
}

variable "cluster_kubeconfig_path" {
  type        = string
  default     = "/home/dario/cube/.talos/configs/kubeconfig"
  description = "Location of kubeconfig file"
}

variable "dns_IPv4" {
  type        = string
  default     = "192.168.1.130"
  description = "IP address of DNS server (Pihole-DNS-Service)"
}

variable "ip_pool_start" {
  type        = string
  default     = "192.168.1.129"
  description = "start of IP pool"
}

variable "ip_pool_end" {
  type        = string
  default     = "192.168.1.135"
  description = "end of IP pool"
}

variable "email" {
  type        = string
  default     = ""
  description = "email address for cert-manager"
  sensitive   = true
}

variable "URL_pihole" {
  type        = string
  default     = "pi.darioludwig.space"
  description = "URL for pihole"
}

variable "cert_manager_name" {
  type        = string
  default     = "letsencrypt-stgng"
  description = "name of cert-manager"
}

variable "cloudflare_dns_api_token" {
  type        = string
  default     = ""
  description = "cloudflare dns api token"
  sensitive   = true
}

variable "cloudflare_api_key" {
  type        = string
  default     = ""
  description = "cloudflare api key"
  sensitive   = true
}