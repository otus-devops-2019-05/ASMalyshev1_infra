terraform {
  backend "gcs" {
    bucket = "sb01"
    prefix = "stage"
  }
}
