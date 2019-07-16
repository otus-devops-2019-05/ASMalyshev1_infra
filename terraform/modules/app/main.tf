resource "google_compute_instance" "app" {
  count        = "${var.count}"
  name         = "reddit-app-${count.index}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  #  tags = ["puma-server"]

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    # использовать ephemeral IP для доступа из Интернет
    access_config {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  #connection {
  #    type        = "ssh"
  #    user        = "appuser"
  #    agent       = false
  #    private_key = "${file(var.private_key_path)}"
  #  }

  #  provisioner "file" {
  #    source      = "puma.service"
  #    destination = "/tmp/puma.service"
  #  }

  #  provisioner "remote-exec" {
  #    script = "deploy.sh"
  #  }
}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"

    ports = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}
