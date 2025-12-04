resource "kubernetes_deployment" "matomo" {
  metadata { name = "matomo" }
  spec {
    replicas = 1
    selector { match_labels = { app = "matomo" } }
    template {
      metadata { labels = { app = "matomo" } }
      spec {
        container {
          name  = "matomo"
          image = var.matomo_image 
          port { container_port = 81 }
          env {
            name = "MATOMO_DATABASE_HOST"
            value = "mariadb-service"
          }
          env {
            name = "MATOMO_DATABASE_USERNAME"
            value = var.db_user
          }
          env {
            name = "MATOMO_DATABASE_PASSWORD"
            value = var.db_password
          }
          env {
            name = "MATOMO_DATABASE_DBNAME"
            value = var.db_name
          }
          volume_mount {
            name       = "matomo-storage"
            mount_path = "/var/www/html"
          }
        }
        volume {
          name = "matomo-storage"
          persistent_volume_claim {
            claim_name = "matomo-pvc"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "matomo" {
  metadata { name = "matomo-service" }
  spec {
    selector = { app = "matomo" }
    type = "NodePort"
    port {
      port        = 80
      target_port = 81
      node_port   = 30081
    }
  }
}