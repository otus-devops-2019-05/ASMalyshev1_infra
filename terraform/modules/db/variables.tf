variable domain_zone {
  description = "App domain zone"
  default     = "*"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default = "reddit-db-base"
}


variable public_key_path {
  description = "Path to the public key used for ssh access"
}
