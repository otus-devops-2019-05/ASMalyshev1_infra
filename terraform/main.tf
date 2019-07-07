terraform {
  # Версия terraform
  # required_version = "0.11.11" #OTUS
  required_version = ">=0.11.11"
  }
  
  provider "google" {
  # Версияпровайдера
  # version = "2.0.0" #OTUS
  version = "~> 2.5"

  # ID проекта
  project = "infra-244306" # Пишем свой индификатор группы в GCP

  region = "europe-west-1"
}
resource "google_compute_instance" "app" {
    name         = "reddit-app"
    machine_type = "g1-small"
    zone         = "europe-west1-b"
    tags = ["reddit-app"]

    #Blocks of type "metadata" are not expected here.
    #https://github.com/terraform-providers/terraform-provider-google/issues/3858
    #Error: "metadata {" | Ok: "metadata = {" 

    metadata = {
        # путь до публичного ключа
        ssh-keys = "appuser:${file("C:\\Users\\asmalyshev\\.ssh\\appuser.pub")}"
        #file("C:\\Users\\asmalyshev\\.ssh\\appuser.pub")}"
    }

    # определение загрузочного диска
    boot_disk {
        initialize_params {
	      image = "reddit-base"
	    }
}
# определение сетевого интерфейса
    network_interface {
     # сеть, к которой присоединить данный интерфейс  
     network = "default"
     # использовать ephemeral IP длядоступа из Интернет
     access_config {}
	}
}
resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"
  # Название сети, в которой действует правило 
  network = "default"
  # Какой доступ разрешить 
  allow {
      protocol = "tcp"
      ports = ["9292"]  
  }  
  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]
  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app"]
}
