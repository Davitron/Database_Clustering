resource "google_compute_network" "db-cluster-network" {
  name      = "db-network"
  auto_create_subnetworks     = "false"
}