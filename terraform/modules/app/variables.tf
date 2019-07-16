variable public_key_path {
  description = "Path to the public key used for ssh access"
}

#variable private_key_path {
#  description = "Path to the private key used for ssh access"
#}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable "count" {
  description = "Number of VMs"
  default     = "1"
}

variable "db-ip" {
  description = "IP of mongodb"
  default     = "localhost"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
