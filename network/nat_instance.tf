resource "google_compute_instance" "nat-instance" {
  name         = "nat-instance"
  machine_type = "${var.machine_type}"
  zone         = "europe-west1-b"
  metadata_startup_script = "${var.startup_scripts["nat"]}"
  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }
  network_interface {
    subnetwork  = "${google_compute_subnetwork.public-subnet.self_link}"
    access_config {
      nat_ip = "${google_compute_address.nat-ip-address.address}"
    }
  }
  can_ip_forward = "true"
  tags = ["public"]
  service_account {
    scopes = ["cloud-platform"]
  }
}