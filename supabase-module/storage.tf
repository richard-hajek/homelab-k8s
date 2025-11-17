# Database Persistent Volume
resource "kubernetes_persistent_volume" "supabase_db_pv" {
  metadata {
    name = "supabase-db-pv"
  }

  spec {
    capacity = {
      storage = "8Gi"
    }

    access_modes                     = ["ReadWriteOnce"]
    storage_class_name               = "local-storage"
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path {
        path = "${var.mount_path}/supabase/db"
        type = "DirectoryOrCreate"
      }
    }
  }
}

# Storage Persistent Volume
resource "kubernetes_persistent_volume" "supabase_storage_pv" {
  metadata {
    name = "supabase-storage-pv"
  }

  spec {
    capacity = {
      storage = "10Gi"
    }

    access_modes                     = ["ReadWriteOnce"]
    storage_class_name               = "local-storage"
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path {
        path = "${var.mount_path}/supabase/storage"
        type = "DirectoryOrCreate"
      }
    }
  }
}
