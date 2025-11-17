resource "kubernetes_namespace" "changedetection" {
  metadata {
    name = "changedetection"
  }
}
