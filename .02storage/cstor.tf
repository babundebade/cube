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

data "kubernetes_resources" "block_devices" {
  api_version = "openebs.io/v1alpha1"
  kind = "BlockDevice"
  namespace = kubernetes_namespace.namespace_openebs.metadata[0].name
}

output "blockdevices" {
  value = [for blockdevice in data.kubernetes_resources.block_devices.objects : {
      NODENAME = blockdevice.spec.nodeAttributes.nodeName
      BLOCKDEVICENAME = blockdevice.metadata.name
      CAPACITY = blockdevice.spec.capacity.storage
  }]
  #for reference: https://pkg.go.dev/github.com/openebs/node-disk-manager/api/v1alpha1#BlockDevice
}

locals {
  blockdevices = [
    for blockdevice in data.kubernetes_resources.block_devices.objects : {
      NODENAME = blockdevice.spec.nodeAttributes.nodeName
      BLOCKDEVICENAME = blockdevice.metadata.name
      CAPACITY = blockdevice.spec.capacity.storage
    } if tonumber(blockdevice.spec.capacity.storage) > 1000000000000
  ]
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
      "pools" = [for bd in local.blockdevices : {
        "nodeSelector" = {
          "kubernetes.io/hostname" = bd.NODENAME
        },
        "dataRaidGroups" = [{
          "blockDevices" = [{
            "blockDeviceName" = bd.BLOCKDEVICENAME
          }]
        }],
        "poolConfig" = {
          "dataRaidGroupType" = "stripe"
        }
      }]
    }
  }
  depends_on = [helm_release.cstor, local.blockdevices]
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
    volume_binding_mode = "WaitForFirstConsumer"
    depends_on = [kubernetes_manifest.openebs_cstor_pool]
}