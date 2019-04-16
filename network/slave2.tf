resource "google_compute_instance" "slave-two" {
  name         = "slave-2-node"
  machine_type = "${var.machine_type}"
  zone         = "europe-west1-b"
  tags         = ["private"]
  boot_disk {
    initialize_params {
      image = "${var.slave_image}"
    }
  }

  network_interface {
    subnetwork  = "${google_compute_subnetwork.private-subnet.self_link}"
    network_ip               = "${var.slave2_ip}"
  }

  metadata {
    master_ip = "${var.master_ip}"
    db_password = "${var.db_password}"
  }

  metadata_startup_script = "${var.startup_scripts["slave"]}"
  service_account {
    scopes = ["cloud-platform"]
  }
}