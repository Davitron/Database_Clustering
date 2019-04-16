provider "google" {
  credentials = "${file("../secrets/google-creds-staging.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
  version     = "~> 1.19"
}