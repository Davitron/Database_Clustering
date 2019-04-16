resource "google_compute_address" "nat-ip-address" {
  name = "nat-ip-address"
  region = "${var.region}"
}

resource "google_compute_address" "haproxy-ip-address" {
  name = "haproxy-ip-address"
  region = "${var.region}"
}