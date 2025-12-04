resource "kubernetes_deployment" "mariadb" {
  metadata { name = "mariadb" }
  spec {
    replicas = 1
    selector { match_labels = { app = "mariadb" } }
    template {
      metadata { labels = { app = "mariadb" } }
      spec {
        container {
          name  = "mariadb"
          image = "mariadb:10.5"
          env {
            name = "MYSQL_ROOT_PASSWORD"
            value = var.db_password
          }
          env {
            name = "MYSQL_DATABASE"
            value = var.db_name
          }
          env {
            name = "MYSQL_USER"
            value = var.db_user
          }
          env {
            name = "MYSQL_PASSWORD"
            value = var.db_password
          }
          volume_mount {
            name       = "mariadb-storage"
            mount_path = "/var/lib/mysql"
          }
        }
        volume {
          name = "mariadb-storage"
          persistent_volume_claim {
            claim_name = "mariadb-pvc"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mariadb" {
  metadata { name = "mariadb-service" }
  spec {
    selector = { app = "mariadb" }
    port {
      port        = 3306
      target_port = 3306
    }
    type = "ClusterIP"
  }
}