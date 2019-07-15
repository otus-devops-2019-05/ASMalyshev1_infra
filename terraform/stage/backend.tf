terraform {
  backend "gcs" {
    bucket = "storage-bucket-testa1"
    prefix = "stage"
  }
}