terraform {
  # версия terraform
  required_version = ">=0.11.11"
}

provider "google" {
  # Версия провайдера
  version = "~> 2.5"

  # id проекта
  project = "${var.project}"

  region = "${var.region}"
}

resource "google_compute_instance" "app" {
  name         = "reddit-app-${count.index + 1}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]
  count        = "${var.instance_count}"

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    # использовать ephemeral IP для доступа из Интернет
    access_config {}
  }

  #Blocks of type "metadata" are not expected here.
  #https://github.com/terraform-providers/terraform-provider-google/issues/3858
  #Error: "metadata {" | Ok: "metadata = {" 

  metadata = {
    # Путь до публичного ключа
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  # Подключение провиженоров к ВМ
  connection {
    type  = "ssh"
    user  = "appuser"
    agent = false
    host  = "146.148.14.4"
    # путь до приватного ключа
    private_key = "${file("C:\\Users\\asmalyshev\\.ssh\\appuser")}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  # Каким адресам разрешать доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применения для инстансов с перечисленными тегами
  target_tags = ["reddit-app"]
}

resource "google_compute_project_metadata" "many_keys" {
  project = "${var.project}"
  metadata = {
    ssh-keys = "appuser2:${file(var.public_key_path)} \nappuser3:${file(var.public_key_path)}"
  }
}
