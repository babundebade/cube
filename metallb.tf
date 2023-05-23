resource "kubernetes_manifest" "namespace_metallb_system" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = "metallb-system"
    }
  }
}

resource "null_resource" "kubeconfig_metallb" {
  provisioner "local-exec" {
    command = "kubectl label ns metallb-system pod-security.kubernetes.io/enforce=privileged"
  }
  depends_on = [kubernetes_manifest.namespace_metallb_system]
}

resource "helm_release" "metallb" {
  name       = "metallb"
  namespace  = "metallb-system"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metallb"

  values = [file("modules/metallb/values.yaml")]
}

resource "null_resource" "metallb-resources" {
  provisioner "local-exec" {
    command = "kubectl apply -f modules/metallb/configmap.yaml"
  }
  depends_on = [helm_release.metallb]
}