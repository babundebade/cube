# Cluster variables
variable "cluster_name" {
  type        = string
  description = "value of cluster_name"
  default     = "talos-cube"
}

variable "cluster_kubeconfig_path" {
  type        = string
  default     = pathexpand("~/cube/.talos/configs/kubeconfig")
  description = "Location of kubeconfig file"
}

# Network and Domain name variables
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

variable "tld_domain" {
  type        = string
  default     = "darioludwig.space"
  description = "top level domain for projects"
}

# Cert-manager variables
variable "email" {
  type        = string
  default     = ""
  description = "email address for cert-manager"
  sensitive   = true
}

variable "root_secret_name" {
  type = string
  default = "root-secret"
}

variable "root_issuer_name" {
  type = string
  default = "root-issuer"
}

variable "root_cert_name" {
  type = string
  default = "root-cert"
}

variable "cert_issuer_name" {
  type        = string
  default     = "cert-issuer"
  description = "name of cert-manager"
}

variable "pihole_cert_name" {
  type        = string
  default     = "pihole-cert"
  description = "name of certificate"
}

variable "pihole_secret_name" {
  type        = string
  default     = "pihole-secret"
  description = "name of secret"
}

# Storage variables
variable "storage_pool_name" {
  type        = string
  default     = "cstor-disk-pool"
  description = "name of storage pool"
}

variable "storage_class_name" {
  type        = string
  default     = "cstor-csi-disk"
  description = "name of standard storage class"
}

