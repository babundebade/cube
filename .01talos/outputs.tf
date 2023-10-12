output "talos-secrets" {
  value = talos_machine_secrets.talos_cube_secrets.machine_secrets
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

resource "local_sensitive_file" "talosconfig_file" {
  content  = data.talos_client_configuration.this.talos_config
  filename = "${path.module}/configs/talosconfig"
}

resource "local_sensitive_file" "kubeconfig_file" {
  content  = data.talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = "${path.module}/configs/kubeconfig"
}

resource "local_sensitive_file" "talos_cube_machine_secrets_file" {
  content  = talos_machine_secrets.talos_cube_secrets.client_configuration.ca_certificate
  filename = "${path.module}/configs/talos_cube_client_ca.crt"  
}

resource "local_sensitive_file" "talos_cube_client_secrets_file" {
  content  = talos_machine_secrets.talos_cube_secrets.machine_secrets.cluster.secret
  filename = "${path.module}/configs/talos_cube_cluster_secret.yaml"  
}

resource "local_sensitive_file" "talosconfig_main_file" {
  content  = data.talos_client_configuration.this.talos_config
  filename = pathexpand("~/.talos/config")

  lifecycle {
    create_before_destroy = true
  }
}

resource "local_sensitive_file" "kubeconfig" {
  content  = data.talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = pathexpand("~/.kube/config")

  # lifecycle {
  #   create_before_destroy = true
  # }
}

resource "local_sensitive_file" "talos_machine_configuration_cp_file" {
  content  = data.talos_machine_configuration.controlplane.machine_configuration
  filename = "${path.module}/configs/talos_machine_configuration_cp.yaml"
}

resource "local_sensitive_file" "talos_machine_configuration_worker_file" {
  content  = data.talos_machine_configuration.worker.machine_configuration
  filename = "${path.module}/configs/talos_machine_configuration_worker.yaml"
}