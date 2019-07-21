variable domain_zone {
  description = "App domain zone"
  default     = "*"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default = "reddit-app-base"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}
