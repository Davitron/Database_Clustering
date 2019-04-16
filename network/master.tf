resource "google_compute_instance" "master" {
  name         = "master-node"
  machine_type = "${var.machine_type}"
  zone         = "europe-west1-b"
  tags         = ["private"]
  metadata_startup_script = "${var.startup_scripts["master"]}"
  boot_disk {
    initialize_params {
      image = "${var.master_image}"
    }
  }
 
  network_interface {
    subnetwork  = "${google_compute_subnetwork.private-subnet.self_link}"
    network_ip                = "${var.master_ip}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}