resource "kubernetes_namespace" "namespace_openebs_jiva" {
  metadata {
    name = "openebs-jiva"
  }
}

resource "null_resource" "kubeconfig_jiva" {
  provisioner "local-exec" {
    command = "kubectl label ns openebs-jiva pod-security.kubernetes.io/audit=privileged pod-security.kubernetes.io/enforce=privileged pod-security.kubernetes.io/warn=privileged"
  }
  depends_on = [kubernetes_namespace.namespace_openebs_jiva]
}

resource "helm_release" "openebs-jiva" {
  name       = "openebs-jiva"
  repository = "https://openebs.github.io/jiva-operator"
  chart      = "jiva"
  namespace  = kubernetes_namespace.namespace_openebs_jiva.metadata[0].name

  values = [
    file("${path.module}/services/openebs-jiva/values.yaml"),
  ]
}

resource "kubernetes_config_map" "configmap_openebs_jiva" {
  metadata {
    name      = "openebs-jiva-config"
    namespace = kubernetes_namespace.namespace_openebs_jiva.metadata[0].name
  }

  data = {
    "openebs-jiva-config" = file("${path.module}/services/openebs-jiva/configmap.yaml")
  }
  depends_on = [kubernetes_namespace.namespace_openebs_jiva]
}

resource "kubernetes_daemonset" "openebs_jiva_csi_node_daemonset" {
  metadata {
    name      = "openebs-jiva-csi-node"
    namespace = kubernetes_namespace.namespace_openebs_jiva.metadata[0].name
  }

  spec {
    selector {
      match_labels = {
        app = "openebs-jiva-csi-node"
      }
    }
    template {
      metadata {
        name = "openebs-jiva-csi-node"
      }
      spec {
        host_pid = true
      }
    }
  }

  depends_on = [helm_release.openebs-jiva]
}
