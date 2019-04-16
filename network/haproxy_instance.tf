resource "google_compute_instance" "haproxy" {
  name         = "haproxy"
  machine_type = "${var.machine_type}"
  zone         = "europe-west1-b"
  tags = ["public", "http-server"]

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

  metadata {
    master_ip = "${var.master_ip}"
    slave1_ip = "${var.slave1_ip}"
    slave2_ip =  "${var.slave2_ip}"
  }

  metadata_startup_script = "${var.startup_scripts["haproxy"]}"

  depends_on = [
    "google_compute_instance.master",
    "google_compute_instance.slave-one",
    "google_compute_instance.slave-two"
  ]

  service_account {
    scopes = ["cloud-platform"]
  }
}