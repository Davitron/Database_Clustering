resource "google_compute_firewall" "ssh-and-icmp-public" {
  name          = "ssh-and-icmp-public"
  network       = "${google_compute_network.db-cluster-network.self_link}"
  allow {
    protocol    = "icmp"
  }

  allow {
    protocol    = "tcp"
    ports       = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["public"]
}

resource "google_compute_firewall" "ssh_and-icmp-private" {
  name          = "ssh-icmp-private"
  network       = "${google_compute_network.db-cluster-network.self_link}"
  allow {
    protocol    = "icmp"
  }

  allow {
    protocol    = "tcp"
    ports       = ["22"]
  }
  source_tags = ["public", "private"]
  target_tags   = ["private"]
}

resource "google_compute_firewall" "internal-connections" {
  name          = "internal"
  network       = "${google_compute_network.db-cluster-network.self_link}"
  allow {
    protocol    = "udp"
    ports       = ["0-65535"]
  }

  allow {
    protocol    = "tcp"
    ports       = ["0-65535"]
  }

  allow {
    protocol    = "icmp"
  }
  source_tags = ["public", "private"]
  target_tags   = ["private", "public"]
}

resource "google_compute_firewall" "outbound-traffic" {
  name               = "outbound"
  direction          = "EGRESS"
  network            = "${google_compute_network.db-cluster-network.self_link}"
  allow {
    protocol    = "tcp"
    ports       = ["80", "8080", "443"]
  }
  destination_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "inbound-http" {
  name          = "inbound-http"
  direction     = "INGRESS"
  network       = "${google_compute_network.db-cluster-network.self_link}"

  allow {
    protocol    = "tcp"
    ports       = ["80", "8080", "7000", "5000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}
