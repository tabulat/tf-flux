provider "flux" {
  kubernetes = {
    host                   = var.config_host
    token                  = var.config_token
    cluster_ca_certificate = var.config_ca
  }
}