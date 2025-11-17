resource "kubernetes_persistent_volume" "changedetection_pv" {
  metadata {
    name = "changedetection-pv"
  }

  spec {
    capacity = {
      storage = "5Gi"
    }

    access_modes                     = ["ReadWriteOnce"]
    storage_class_name               = "local-storage"
    persistent_volume_reclaim_policy = "Retain"

    claim_ref {
      namespace = kubernetes_namespace.changedetection.metadata[0].name
      name      = "changedetection-data"
    }

    persistent_volume_source {
      host_path {
        path = "${var.mount_path}/changedetection"
        type = "DirectoryOrCreate"
      }
    }
  }
}
