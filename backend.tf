terraform {
  backend "gcs" {
    bucket = "tf-state-img-studio-terraform-deploy"
  }
}
