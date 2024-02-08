resource "kubernetes_secret" "cloudflare_api_token_secret" {
  metadata {
    name      = var.pihole_secret_name#"cloudflare-api-token-secret"  # This name should be constant and descriptive
    namespace = "cert-manager"
  }
  type = "Opaque"

  # The token value should be base64 encoded when using `data`. 
  # If you want to use plain text, you should use `stringData` instead.
  data = {
    "api-token" = var.cloudflareToken
  }
}

resource "kubernetes_manifest" "letsencrypt_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = var.cert_issuer_name  # e.g., "letsencrypt-staging"
    }
    spec = {
      acme = {
        email  = var.email
        server = "https://acme-v02.api.letsencrypt.org/directory" #"https://acme-staging-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "letsencrypt-production" #"letsencrypt-staging"
        }
        solvers = [
          {
            dns01 = {
              cloudflare = {
                email           = var.email
                apiTokenSecretRef = {
                  name = kubernetes_secret.cloudflare_api_token_secret.metadata[0].name
                  key  = "api-token"  # This should match the key used in the secret above
                }
              }
            }
          }
        ]
      }
    }
  }
}