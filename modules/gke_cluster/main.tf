provider "google" {
  # Configuration options
  project = var.GOOGLE_PROJECT
  region  = var.GOOGLE_REGION
}

resource "google_container_cluster" "this" {
  name     = var.GKE_CLUSTER_NAME
  location = var.GOOGLE_REGION

  initial_node_count       = 1
  remove_default_node_pool = true  
  deletion_protection      = false
}

resource "google_container_node_pool" "this" {
  name       = var.GKE_POOL_NAME
  project    = google_container_cluster.this.project
  cluster    = google_container_cluster.this.name
  location   = google_container_cluster.this.location
  node_count = var.GKE_NUM_NODES

  node_config {
    machine_type = var.GKE_MACHINE_TYPE
    disk_size_gb = 20
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

module "gke_auth" {
  depends_on = [
    google_container_cluster.this
  ]
  source               = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version              = ">=24.0.0" # newest
  project_id           = var.GOOGLE_PROJECT
  cluster_name         = google_container_cluster.this.name
  location             = var.GOOGLE_REGION
}

data "google_client_config" "current" {}

data "google_container_cluster" "main" {
  name     = google_container_cluster.this.name
  location = var.GOOGLE_REGION  
} 

#resource "local_file" "kubeconfig" {
#  content  = module.gke_auth.kubeconfig_raw
#  filename = "${path.module}/kubeconfig"
#}