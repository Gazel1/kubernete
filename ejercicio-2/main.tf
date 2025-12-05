terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    kind = {
      source = "tehcyx/kind"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-cluster-ej2"
}

# PVC para MariaDB
resource "kubernetes_persistent_volume_claim_v1" "mariadb_pvc" {
  metadata {
    name = "mariadb-pvc"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

# PVC para Matomo
resource "kubernetes_persistent_volume_claim_v1" "matomo_pvc" {
  metadata {
    name = "matomo-pvc"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}