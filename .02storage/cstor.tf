resource "kubernetes_namespace" "namespace_openebs" {
    metadata {
        name = "openebs"
    }
}

resource "kubernetes_node_taint" "taint_ssd_node_11" {
  metadata {
    name = "cntrlpln-11-yellow"
  }
  taint {
    key    = "node-role.kubernetes.io/ssd"
    value  = "true"
    effect = "PreferNoSchedule"
  }
}

resource "kubernetes_node_taint" "taint_ssd_node_12" {
  metadata {
    name = "cntrlpln-12-red"
  }
  taint {
    key    = "node-role.kubernetes.io/ssd"
    value  = "true"
    effect = "PreferNoSchedule"
  }
}

resource "helm_release" "cstor" {
  name       = "openebs"
  #repository = "https://github.com/openebs/openebs/tree/main/k8s/charts/" #"https://openebs.github.io/charts/openebs/"
  chart      = "https://github.com/openebs/openebs/blob/main/k8s/charts/openebs/Chart.yaml" #"openebs"
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
