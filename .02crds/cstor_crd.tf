resource "kubernetes_namespace" "namespace_openebs" {
    metadata {
        name = "openebs"
    }
}

resource "kubernetes_labels" "label_ssd_node_11" {
  api_version = "v1"
  kind = "Node"
  metadata {
    name = "cntrlpln-11-yellow"
  }
  labels = {
    "ssd" = "true"
  }
}

resource "kubernetes_labels" "label_ssd_node_12" {
  api_version = "v1"
  kind = "Node"
  metadata {
    name = "cntrlpln-12-red"
  }
  labels = {
    "ssd" = "true"
  }
}

resource "helm_release" "cstor" {
  name       = "openebs"
  repository = "https://openebs.github.io/charts"
  chart      = "openebs"
  #version    = "3.10.0"
  namespace  = kubernetes_namespace.namespace_openebs.metadata[0].name

  set {
    name  = "cstor.enabled"
    value = "true"
  }

  set {
    name  = "openebs-ndm.enabled"
    value = "true"
  }

  set {
    name  = "jiva.enabled"
    value = "false"
  }

  set {
    name  = "localpv-provisioner.enabled"
    value = "false"
  }

  set {
    name  = "zfs-localpv.enabled"
    value = "false"
  }

  set {
    name  = "lvm-localpv.enabled"
    value = "false"
  }

  set {
    name  = "nfs-provisioner.enabled"
    value = "false"
  }

  set {
    name  = "mayastor.enabled"
    value = "false"
  }

  // Additional configuration for CSPC and other cStor settings can be added here
  // For example, to set specific image tags or enable certain features

  // It's important to review and adjust these settings based on your specific requirements and cluster configuration
}