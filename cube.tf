provider "talos" {
  # Configuration options
}

resource "talos_machine_secrets" "cube" {}

data "talos_machine_configuration" "cube" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = "https://192.168.1.11:6443"
  machine_secrets  = talos_machine_secrets.cube.machine_secrets
}

data "talos_client_configuration" "cube" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.cube.client_configuration
  nodes                 = ["192.168.1.11"]
}

/* resource "talos_machine_bootstrap" "cube" {
  depends_on = [
    talos_machine_configuration_apply.cube
  ]
  node                 = "192.168.1.13"
  client_configuration  = talos_machine_secrets.cube.client_configuration 
} */

/* resource "talos_machine_configuration_apply" "cube" {
  client_configuration        = talos_machine_secrets.cube.client_configuration
  machine_configuration_input = data.talos_machine_configuration.cube.machine_configuration
  node                        = "192.168.1.13"
  # config_patches = [
  #   yamlencode({
  #     machine = {
  #       install = {
  #         disk = "/dev/sdd"
  #       }
  #     }
  #   })
  # ]
} */

provider "kubernetes" {
  host = "https://192.168.1.11:6443"
  config_path = var.cluster_kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.cluster_kubeconfig_path
  }
}

resource "kubernetes_manifest" "metallb-configmap" {
  manifest = file("modules/metallb/configmap.yaml")  
}

resource "helm_release" "metallb" {
  name       = "metallb"
  namespace  = "metallb-system"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metallb"

  values = [file("modules/metallb/metallb_values.yaml")]

  depends_on = [kubernetes_manifest.metallb-configmap]
}


/* resource "kubernetes_service" "ingress-service" {
  metadata {
    name = "ingress-service"
  }
  spec {
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    type = "NodePort"
  }
}

resource "kubernetes_ingress" "nginx-ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "nginx-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }
  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service_name = kubernetes_service.ingress-service.metadata.0.name
            service_port = 80
          }
        }
      }
    }
  }
}

# Display load balancer hostname (typically present in AWS)
output "load_balancer_hostname" {
  value = kubernetes_ingress.nginx-ingress.status.0.load_balancer.0.ingress.0.hostname
}

# Display load balancer IP (typically present in GCP, or using Nginx ingress controller)
output "load_balancer_ip" {
  value = kubernetes_ingress.nginx-ingress.status.0.load_balancer.0.ingress.0.ip
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-controller"
  namespace  = "nginx-ingress-ns"
  create_namespace = true
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  values = [file("nginx-ingress/nginx_ingress_values.yaml")]
} */