resource "kubernetes_namespace" "namespace_cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

# resource "kubernetes_manifest" "namespace_cert_manager" {
#   manifest = {
#     "apiVersion" = "v1"
#     "kind"       = "Namespace"
#     "metadata" = {
#       "name" = "cert-manager"
#     }
#   }
# }

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
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

resource "null_resource" "cert-manager_issuer" {
  provisioner "local-exec" {
    command = "envsubst < ${path.module}/services/cert-manager/issuer.yaml | kubectl apply -f -"

    environment = {
      EMAIL = var.email
      CERT_MANAGER_NAME = var.cert_manager_name
    }
  }
  depends_on = [helm_release.cert-manager, null_resource.cloudflare_api_key_secret]
  lifecycle {
    replace_triggered_by = [terraform_data.cert-manager_email, terraform_data.cert-manager_name]
  }
}

# resource "terraform_data" "cloudflare_dns_api_token" {
#   input = var.cloudflare_dns_api_token
# }

# resource "null_resource" "cloudflare_token_secret" {
#   provisioner "local-exec" {
#     command = "envsubst < ${path.module}/services/cert-manager/cloudflare-secret.yaml | kubectl apply -f -"

#     environment = {
#       CLOUDFLARE_API_TOKEN = var.cloudflare_dns_api_token
#     }
#   }
#   lifecycle {
#     replace_triggered_by = [terraform_data.cloudflare_dns_api_token]
#   }
# }

resource "terraform_data" "cloudflare_api_key" {
  input = var.cloudflare_api_key
}

resource "null_resource" "cloudflare_api_key_secret" {
  provisioner "local-exec" {
    command = "envsubst < ${path.module}/services/cert-manager/cloudflare-api-key-secret.yaml | kubectl apply -f -"

    environment = {
      CLOUDFLARE_API_KEY = var.cloudflare_api_key
    }
  }
  lifecycle {
    replace_triggered_by = [terraform_data.cloudflare_api_key]
  }
}