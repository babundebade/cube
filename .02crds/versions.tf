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