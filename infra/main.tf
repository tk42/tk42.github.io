resource "google_compute_address" "brain_ip" {
  name = "brain-static-ip"
}

resource "google_compute_instance" "brain" {
  name         = "tk42-brain"
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 30
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.brain_ip.address
    }
  }

  metadata_startup_script = file("${path.module}/../scripts/setup_vm.sh")

  tags = ["http-server", "https-server"]
}

resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "https-server"]
}
