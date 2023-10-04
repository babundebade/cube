resource "kubernetes_namespace" "namespace_cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  namespace  = resource.kubernetes_namespace.namespace_cert_manager.metadata[0].name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager" #jetstack/cert-manager

  values = [file("${path.module}/services/cert-manager/values.yaml")]

  depends_on = [kubernetes_namespace.namespace_cert_manager, helm_release.metallb]
}

resource "terraform_data" "cert-manager_email" {
  input = var.email
}

resource "terraform_data" "cert-manager_name" {
  input = var.cert_manager_name
}

resource "null_resource" "root_issuer" {
  provisioner "local-exec" {
    command = "envsubst < ${path.module}/services/cert-manager/root-issuer.yaml | kubectl apply -f -"

    # environment = {
    #   EMAIL = var.email
    #   CERT_MANAGER_NAME = var.cert_manager_name
    #   CERT_MANAGER_NAMESPACE = resource.kubernetes_namespace.namespace_cert_manager.metadata[0].name
    # }
  }
    
  # lifecycle {
  #   replace_triggered_by = [terraform_data.cert-manager_email, terraform_data.cert-manager_name]
  # }

  depends_on = [helm_release.cert-manager]
}

resource "null_resource" "root_cert" {
  provisioner "local-exec" {
    command = "envsubst < ${path.module}/services/cert-manager/root-cert.yaml | kubectl apply -f -"

    # environment = {
    #   EMAIL = var.email
    #   CERT_MANAGER_NAME = var.cert_manager_name
    #   CERT_MANAGER_NAMESPACE = resource.kubernetes_namespace.namespace_cert_manager.metadata[0].name
    # }
  }
    
  # lifecycle {
  #   replace_triggered_by = [terraform_data.cert-manager_email, terraform_data.cert-manager_name]
  # }

  depends_on = [null_resource.root_issuer]
}

resource "null_resource" "cert_issuer" {
  provisioner "local-exec" {
    command = "envsubst < ${path.module}/services/cert-manager/cert-issuer.yaml | kubectl apply -f -"

    # environment = {
    #   EMAIL = var.email
    #   CERT_MANAGER_NAME = var.cert_manager_name
    #   CERT_MANAGER_NAMESPACE = resource.kubernetes_namespace.namespace_cert_manager.metadata[0].name
    # }
  }
    
  # lifecycle {
  #   replace_triggered_by = [terraform_data.cert-manager_email, terraform_data.cert-manager_name]
  # }

  depends_on = [null_resource.root_cert]
}

# resource "terraform_data" "cloudflare_api_key" {
#   input = var.cloudflare_api_key
# }

# resource "null_resource" "cloudflare_api_key_secret" {
#   provisioner "local-exec" {
#     command = "envsubst < ${path.module}/services/cert-manager/cloudflare-api-key-secret.yaml | kubectl apply -f -"

#     environment = {
#       CLOUDFLARE_API_KEY = var.cloudflare_api_key
#     }
#   }
#   lifecycle {
#     replace_triggered_by = [terraform_data.cloudflare_api_key]
#   }
# }