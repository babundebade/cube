# resource "kubernetes_namespace" "mayastor_namespace" {
#   metadata {
#     name = "mayastor"
#   }
# }

# resource "helm_release" "mayastor" {
#   name       = "mayastor"
#   repository = "https://openebs.github.io/mayastor-extensions/"
#   chart      = "mayastor"
#   namespace  = kubernetes_namespace.mayastor_namespace.metadata[0].name

#   values = [
#     file("${path.module}/services/mayastor/values.yaml"),
#   ]
# }