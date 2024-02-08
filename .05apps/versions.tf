### 02 - CRDs
variable "version_cert_manager" {
  type        = string
  default     = "v1.13.3"   #24.01.2024
  description = "version of cert-manager"
}

variable "version_openebs" {
  type        = string
  default     = "3.10.0"    #24.01.2024
  description = "version of openebs"
}

variable "version_metallb" {
  type        = string
  default     = "v0.13.12"  #24.01.2024
  description = "version of metallb"
}

### 04 - Infrastructure
variable "version_nginx_ingress" {
  type        = string
  default     = "4.9.1"    #08.02.2024
  description = "version of nginx-ingress"
}

variable "version_pihole" {
  type        = string
  default     = "2.21.0"    #08.02.2024
  description = "version of pihole"
}

### 05 - Apps
variable "version_home_assistant" {
  type        = string
  default     = "0.2.33"   #08.02.2024
  description = "version of home-assistant"
}