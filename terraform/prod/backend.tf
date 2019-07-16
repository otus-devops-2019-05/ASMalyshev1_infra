terraform {
  backend "gcs" {
    bucket = "sb02"
    prefix = "prod"
  }
}
