resource "tls_private_key" "cert_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "ca_crt" {
  content  = tls_private_key.cert_key.private_key_pem
  filename = pathexpand("~/cube/certs/ca.crt")
}

resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.cert_key.private_key_pem

  subject {
    common_name = var.tld_domain
    country = "DE"
    organization = "Dario"
  }
  is_ca_certificate = true
  validity_period_hours = 8760

  allowed_uses = ["cert_signing"]
}

resource "local_sensitive_file" "x509_ca_crt" {
  content  = tls_self_signed_cert.cert.cert_pem
  filename = pathexpand("~/cube/certs/x509_ca.crt")
}

resource "kubernetes_secret" "root_secret" {
  metadata {
    name = var.root_secret_name
    namespace = var.namespacecertmanager
  }

  data = {
    "tls.crt" = tls_self_signed_cert.cert.cert_pem
    "tls.key" = tls_private_key.cert_key.private_key_pem
  }
}

resource "kubernetes_manifest" "root_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = var.root_issuer_name
    }
    spec = {
      selfSigned = {}
    }
  }
}

resource "kubernetes_manifest" "root_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = var.root_cert_name
      namespace = var.namespacecertmanager
    }
    spec = {
      isCA        = true
      commonName  = var.root_cert_name
      secretName  = var.root_secret_name
      privateKey = {
        algorithm = "ECDSA"
        size      = 256
      }
      issuerRef = {
        name  = var.root_issuer_name
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }
}

resource "kubernetes_manifest" "cert_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = var.cert_issuer_name
    }
    spec = {
      ca = {
        secretName = var.root_secret_name
      }
    }
  }
}