resource "kubernetes_persistent_volume" "n8n_pv" {
  metadata {
    name = "n8n-pv"
  }

  spec {
    capacity = {
      storage = "5Gi"
    }

    access_modes                     = ["ReadWriteOnce"]
    storage_class_name               = "local-storage"
    persistent_volume_reclaim_policy = "Retain"

    claim_ref {
      namespace = kubernetes_namespace.n8n.metadata[0].name
      name      = "n8n-data"
    }

    persistent_volume_source {
      host_path {
        path = "${var.mount_path}/n8n"
        type = "DirectoryOrCreate"
      }
    }
  }
}
