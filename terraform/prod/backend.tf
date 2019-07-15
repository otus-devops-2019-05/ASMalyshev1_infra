terraform {
  backend "gcs" {
    bucket = "storage-bucket-testb2"
    prefix = "stage"
  }
}