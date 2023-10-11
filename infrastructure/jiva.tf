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

resource "null_resource" "jiva_daemonset_patch" {
  provisioner "local-exec" {
    command = "kubectl patch daemonset openebs-jiva-csi-node -n openebs-jiva --type='json' -p='[{\"op\": \"replace\", \"path\": \"/spec/template/spec/hostPID\", \"value\": true}]'"
  }
  depends_on = [helm_release.openebs-jiva, kubernetes_config_map.configmap_openebs_jiva]
}


