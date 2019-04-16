 resource "google_compute_route" "subnet-route-config" { 
  name        = "db-cluster-ip-route"
  dest_range  = "0.0.0.0/0"
  network     = "${google_compute_network.db-cluster-network.self_link}"
  next_hop_instance = "${google_compute_instance.nat-instance.self_link}"
  priority    = 800
  tags = ["private"]
}