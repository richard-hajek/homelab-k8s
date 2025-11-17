# Changedetection PVC
resource "kubernetes_persistent_volume_claim" "changedetection_data" {
  metadata {
    name      = "changedetection-data"
    namespace = kubernetes_namespace.changedetection.metadata[0].name
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "local-storage"
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

# Changedetection Deployment
resource "kubernetes_deployment" "changedetection" {
  metadata {
    name      = "changedetection"
    namespace = kubernetes_namespace.changedetection.metadata[0].name
    labels = {
      app = "changedetection"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "changedetection"
      }
    }

    template {
      metadata {
        labels = {
          app = "changedetection"
        }
      }

      spec {
        container {
          name  = "changedetection"
          image = "dgtlmoon/changedetection.io"

          port {
            container_port = 5000
            name           = "http"
          }

          env {
            name  = "PLAYWRIGHT_DRIVER_URL"
            value = "ws://localhost:3000"
          }

          env {
            name  = "TZ"
            value = "Europe/Prague"
          }

          volume_mount {
            name       = "changedetection-data"
            mount_path = "/datastore"
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }
        }

        container {
          name  = "browser-sockpuppet"
          image = "dgtlmoon/sockpuppetbrowser:latest"

          port {
            container_port = 3000
            name           = "browser"
          }

          env {
            name  = "SCREEN_WIDTH"
            value = "1920"
          }

          env {
            name  = "SCREEN_HEIGHT"
            value = "1024"
          }

          env {
            name  = "SCREEN_DEPTH"
            value = "16"
          }

          env {
            name  = "MAX_CONCURRENT_CHROME_PROCESSES"
            value = "10"
          }

          security_context {
            capabilities {
              add = ["SYS_ADMIN"]
            }
          }

          resources {
            requests = {
              memory = "512Mi"
              cpu    = "200m"
            }
            limits = {
              memory = "1Gi"
              cpu    = "1000m"
            }
          }
        }

        volume {
          name = "changedetection-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.changedetection_data.metadata[0].name
          }
        }
      }
    }
  }
}

# Changedetection Service
resource "kubernetes_service" "changedetection" {
  metadata {
    name      = "changedetection"
    namespace = kubernetes_namespace.changedetection.metadata[0].name
    labels = {
      app = "changedetection"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      port        = 5000
      target_port = 5000
      protocol    = "TCP"
      name        = "http"
    }

    selector = {
      app = "changedetection"
    }
  }
}

# Changedetection Ingress
resource "kubernetes_ingress_v1" "changedetection" {
  metadata {
    name      = "changedetection-ingress"
    namespace = kubernetes_namespace.changedetection.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "changedetector.lan"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.changedetection.metadata[0].name
              port {
                number = 5000
              }
            }
          }
        }
      }
    }
  }
}
