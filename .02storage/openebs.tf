resource "kubernetes_namespace" "namespace_openebs" {
  metadata {
    name = "openebs"
  }
}

resource "null_resource" "kubeconfig_openebs" {
  provisioner "local-exec" {
    command = "kubectl label ns openebs pod-security.kubernetes.io/audit=privileged pod-security.kubernetes.io/enforce=privileged pod-security.kubernetes.io/warn=privileged"
  }
  depends_on = [kubernetes_namespace.namespace_openebs]
}

resource "helm_release" "openebs" {
  name       = "openebs"
  repository = "https://openebs.github.io/charts"
  chart      = "openebs"
  namespace  = kubernetes_namespace.namespace_openebs.metadata[0].name
  version    = "3.9.0"

  values = [
    file("${path.module}/services/openebs/values.yaml"),
  ]
  depends_on = [kubernetes_namespace.namespace_openebs, null_resource.kubeconfig_openebs]
}

resource "null_resource" "label_nodes" {
  provisioner "local-exec" {
    command = "kubectl label nodes worker-11 ssd=true && kubectl label nodes worker-12 ssd=true"
  }
}

resource "kubernetes_manifest" "openebs_cstor_pool" {
  manifest = {
    "apiVersion" = "cstor.openebs.io/v1"
    "kind"       = "CStorPoolCluster"
    "metadata" = {
      "name"      = var.storage_pool_name
      "namespace" = kubernetes_namespace.namespace_openebs.metadata[0].name
    }
    "spec" = {
      "pools" = [{
        "nodeSelector" = {
          "kubernetes.io/hostname" = "worker-11"
        },
        "dataRaidGroups" = [{
          "blockDevices" = [{
            "blockDeviceName" = "blockdevice-127890b4e51149504156f5a1428d1c49"
          }]
        }],
        "poolConfig" = {
          "dataRaidGroupType" = "stripe"
        }
        },
        {
          "nodeSelector" = {
            "kubernetes.io/hostname" = "worker-12"
          },
          "dataRaidGroups" = [{
            "blockDevices" = [{
              "blockDeviceName" = "blockdevice-15cd22f9e67611aafe483422558beb5e"
            }]
          }],
          "poolConfig" = {
            "dataRaidGroupType" = "stripe"
          }
      }]
    }
  }
  depends_on = [helm_release.openebs]
}

resource "null_resource" "openebs_csi_iscsiadm" {
  provisioner "local-exec" {
    command = "kubectl --namespace openebs apply --filename services/openebs/configmap.yaml"
  }
  depends_on = [helm_release.openebs]
}

resource "null_resource" "openebs_daemonset_patch" {
  provisioner "local-exec" {
    command = "kubectl --namespace openebs patch daemonset openebs-jiva-csi-node --type=json --patch '[{'op': 'add', 'path': '/spec/template/spec/hostPID', 'value': true}]'"
  }
  depends_on = [helm_release.openebs, null_resource.openebs_csi_iscsiadm]
}

# resource "kubernetes_manifest" "openebs_cstor_csi_node_patch" {
#   manifest = {
#     "apiVersion" = "apps/v1"
#     "kind"       = "DaemonSet"
#     "metadata" = {
#       "name"      = "openebs-cstor-csi-node"
#       "namespace" = kubernetes_namespace.namespace_openebs.metadata[0].name
#     }
#     "spec" = {
#       "template" = {
#         "spec" = {
#           "hostPID" = true
#         }
#       }
#     }
#   }
#   depends_on = [helm_release.openebs, null_resource.openebs_csi_iscsiadm]
# }

# resource "kubernetes_storage_class_v1" "cstor_csi_disk" {
#   metadata {
#     name = var.storage_class_name
#     annotations = {
#       "storageclass.kubernetes.io/is-default-class" = "true"
#     }
#   }
#   storage_provisioner = "cstor.csi.openebs.io"
#   reclaim_policy      = "Retain"
#   parameters = {
#     cas-type         = "cstor"
#     cstorPoolCluster = var.storage_pool_name
#     replicaCount     = "2"
#   }
#   volume_binding_mode    = "WaitForFirstConsumer"
#   allow_volume_expansion = true
#   depends_on             = [kubernetes_manifest.openebs_cstor_pool]
# }
