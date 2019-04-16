resource "google_compute_instance" "haproxy" {
  name         = "haproxy"
  machine_type = "${var.machine_type}"
  zone         = "europe-west1-b"
  tags = ["http-server", "public"]

  boot_disk {
    initialize_params {
      image = "${var.haproxy_image}"
    }
  }
  network_interface {
    subnetwork  = "${google_compute_subnetwork.public-subnet.self_link}"

    access_config {
      nat_ip = "${google_compute_address.haproxy-ip-address.address}"
    }
  }

  lifecycle {
    create_before_destroy   = true
  }


  metadata_startup_script = "${var.startup_scripts["haproxy"]}"

  service_account {
    scopes = ["cloud-platform"]
  }
}