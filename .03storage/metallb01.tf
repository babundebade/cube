resource "kubernetes_namespace" "metallb_namespace" {
  metadata {
    name = "metallb-system"
  }
}

resource "kubernetes_labels" "label_metallb_namespace" {
  api_version = "v1"
  kind = "Namespace"
  metadata {
    name = kubernetes_namespace.metallb_namespace.metadata[0].name
  }

  labels = {
    "pod-security.kubernetes.io/enforce" = "privileged"
    "pod-security.kubernetes.io/audit" = "privileged"
    "pod-security.kubernetes.io/warn" = "privileged"
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  namespace  = kubernetes_namespace.metallb_namespace.metadata[0].name
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"

  #values = [file("services/metallb/values.yaml")]
  depends_on = [ kubernetes_labels.label_metallb_namespace ]
}