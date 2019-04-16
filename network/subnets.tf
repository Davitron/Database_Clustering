resource "google_compute_subnetwork" "public-subnet" {
  name    = "db-network-public-subnet"
  ip_cidr_range     = "${var.public_subnet_cidr}"
  network     = "${google_compute_network.db-cluster-network.self_link}"
}

resource "google_compute_subnetwork" "private-subnet" {
  name    = "db-network-private-subnet"
  ip_cidr_range     = "${var.private_subnet_cidr}"
  network     = "${google_compute_network.db-cluster-network.self_link}"
}