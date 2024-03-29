resource "kubernetes_namespace" "namespace_cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  namespace  = resource.kubernetes_namespace.namespace_cert_manager.metadata[0].name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  values = [file("${path.module}/services/cert-manager/values.yaml")]

  depends_on = [kubernetes_namespace.namespace_cert_manager, helm_release.metallb]
}

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

  depends_on = [ helm_release.cert-manager ]
}

resource "local_sensitive_file" "x509_ca_crt" {
  content  = tls_self_signed_cert.cert.cert_pem
  filename = pathexpand("~/cube/certs/x509_ca.crt")
}

resource "kubernetes_secret" "root_secret" {
  metadata {
    name = var.root_secret_name
    namespace = resource.kubernetes_namespace.namespace_cert_manager.metadata[0].name
  }

  data = {
    "tls.crt" = tls_self_signed_cert.cert.cert_pem
    "tls.key" = tls_private_key.cert_key.private_key_pem
  }
}

resource "k8s_cert_manager_io_cluster_issuer_v1" "root_issuer" {
  metadata = {
    name      = var.root_issuer_name
    namespace = resource.kubernetes_namespace.namespace_cert_manager.metadata[0].name
  }
  spec = {
    self_signed = {}
  }
  depends_on = [ helm_release.cert-manager ]
}

resource "k8s_cert_manager_io_certificate_v1" "root_cert" {
  metadata = {
    name = var.root_cert_name
    namespace = resource.kubernetes_namespace.namespace_cert_manager.metadata[0].name
  }
  spec = {
    is_ca = true
    common_name = var.root_cert_name
    secret_name = resource.kubernetes_secret.root_secret.metadata[0].name
    private_key = {
      algorithm = "ECDSA"
      size = 256
    }
    issuer_ref = {
      name = var.root_issuer_name
      kind = "ClusterIssuer"
      group = "cert-manager.io"
    }
  }
}

resource "k8s_cert_manager_io_cluster_issuer_v1" "cert_issuer" {
  metadata = {
    name = var.cert_issuer_name
    namespace = resource.kubernetes_namespace.namespace_cert_manager.metadata[0].name
  }

  spec = {
    ca = {
      secret_name = var.root_secret_name
    }
  }

  depends_on = [ helm_release.cert-manager ]
}