variable "source_ranges" {
  description = "Available source ranges"
  default     = ["0.0.0.0/0"]
}

variable public_key_path {
  description = "Path to the public key used to connect to instance"
}
