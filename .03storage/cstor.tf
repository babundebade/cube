data "kubernetes_resources" "block_devices" {
  api_version = "openebs.io/v1alpha1"
  kind = "BlockDevice"
  namespace = "openebs"
}

output "blockdevices" {
  value = [for blockdevice in data.kubernetes_resources.block_devices.objects : {
      NODENAME = blockdevice.spec.nodeAttributes.nodeName
      BLOCKDEVICENAME = blockdevice.metadata.name
      CAPACITY = blockdevice.spec.capacity.storage
  }]
  #for reference: https://pkg.go.dev/github.com/openebs/node-disk-manager/api/v1alpha1#BlockDevice
}

# locals {
#   blockdevices = [
#     for blockdevice in data.kubernetes_resources.block_devices.objects : {
#       NODENAME = blockdevice.spec.nodeAttributes.nodeName
#       BLOCKDEVICENAME = blockdevice.metadata.name
#       CAPACITY = blockdevice.spec.capacity.storage
#     } if tonumber(blockdevice.spec.capacity.storage) > 1000000000000
#   ]
# }

resource "kubernetes_manifest" "openebs_cstor_pool" {
  manifest = {
    "apiVersion" = "cstor.openebs.io/v1"
    "kind"       = "CStorPoolCluster"
    "metadata" = {
      "name"      = var.storage_pool_name
      "namespace" = "openebs"
    }
    "spec" = {
      "pools" = [for bd in data.kubernetes_resources.block_devices.objects : {
        "nodeSelector" = {
          "kubernetes.io/hostname" = bd.spec.nodeAttributes.nodeName
        },
        "dataRaidGroups" = [{
          "blockDevices" = [{
            "blockDeviceName" = bd.metadata.name
          }]
        }],
        "poolConfig" = {
          "dataRaidGroupType" = "stripe"
        }
      }]
    }
  }
}

resource "kubernetes_storage_class_v1" "cstor_csi_disk" {
    metadata {
      name = var.storage_class_name
      annotations = {
        "storageclass.kubernetes.io/is-default-class" = "true"
      }
    }
    storage_provisioner = "cstor.csi.openebs.io"
    reclaim_policy = "Retain"
    parameters = {
      cas-type = "cstor"
      cstorPoolCluster = var.storage_pool_name
      replicaCount = "1"
    }
    allow_volume_expansion = false
    volume_binding_mode = "Immediate"
    depends_on = [kubernetes_manifest.openebs_cstor_pool]
}