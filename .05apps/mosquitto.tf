resource "kubernetes_namespace" "mqtt_namespace" {
  metadata {
    name = "mqtt"
  }
}

resource "kubernetes_labels" "label_mqtt_namespace" {
  api_version = "v1"
  kind = "Namespace"
  metadata {
    name = kubernetes_namespace.mqtt_namespace.metadata[0].name
  }

  labels = {
  }
}

resource "helm_release" "mosquitto" {
  name       = "mosquitto"
  namespace  = kubernetes_namespace.mqtt_namespace.metadata[0].name
  repository = "https://storage.googleapis.com/t3n-helm-charts"
  chart      = "mosquitto"

  #values = [file("services/mosquitto/values.yaml")]
  depends_on = [kubernetes_namespace.mqtt_namespace]
  
}