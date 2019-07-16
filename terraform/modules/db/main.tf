resource "google_compute_instance" "db" {
  count        = "${var.count}"
  name         = "reddit-db-${count.index}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-db"]

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  #  tags = ["puma-server"]

  network_interface {
    network       = "default"
    access_config = {}
  }
}

# Правило firewall
resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  target_tags = ["reddit-db"]
  source_tags = ["reddit-app"]
}
