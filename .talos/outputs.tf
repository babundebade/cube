output "talos-secrets" {
  value = talos_machine_secrets.this.machine_secrets
  sensitive = true
}

output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

# resource "local_sensitive_file" "talos-secrets" {
#   content = output.talos-secrets.value
#   filename = "${path.module}/configs/talossecrets.yaml"
# }

resource "local_sensitive_file" "talosconfig_file" {
  content  = data.talos_client_configuration.this.talos_config
  filename = "${path.module}/configs/talosconfig"
}

resource "local_sensitive_file" "kubeconfig_file" {
  content  = data.talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = "${path.module}/configs/kubeconfig"
}

resource "local_sensitive_file" "talosconfig_main_file" {
  content  = data.talos_client_configuration.this.talos_config
  filename = pathexpand("~/.talos/config")
}

resource "local_sensitive_file" "kubeconfig" {
  content  = data.talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = pathexpand("~/.kube/config")
}