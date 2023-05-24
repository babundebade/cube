# # For future use

# mikrotik = {
#   source  = "kube-cloud/mikrotik"
#   version = "0.12.0"
# }

# provider "mikrotik" {
#   host           = "192.168.1.1:8728"           # Or set MIKROTIK_HOST environment variable
#   username       = var.mikrotik_access.username # Or set MIKROTIK_USER environment variable
#   password       = var.mikrotik_access.password # Or set MIKROTIK_PASSWORD environment variable
#   tls            = false                        # Or set MIKROTIK_TLS environment variable
#   ca_certificate = ""                           # Or set MIKROTIK_CA_CERTIFICATE environment variable
#   insecure       = true                         # Or set MIKROTIK_INSECURE environment variable
# }

# resource "mikrotik_dhcp_server_network" "smarthome" {
#   address    = "192.168.100.0/24"
#   netmask    = "0" # use mask from address
#   gateway    = "192.168.1.1"
#   dns_server = "192.168.1.1"
#   comment    = "Default DHCP server network"
# }

# variable "mikrotik_access" {
#   type = object({
#     username = string
#     password = string
#   })
#   sensitive = false
# }

# mikrotik_access = {
#   username = "xxx"
#   password = "xxx"
# }