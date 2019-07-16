variable public_key_path {
  description = "Path to the public key used to connect to instance"
}

variable zone {
  description = "Zone"
}

variable app_disk_image {
  description = "Disk image for reddit app"

  default = "reddit-app-base"
}

variable app_external_ip {
  default = "google_compute_instance.app.network_interface.0.access_config.0.assigned_nat_ip"
}
