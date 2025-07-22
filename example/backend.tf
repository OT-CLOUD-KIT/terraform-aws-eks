terraform {
  backend "s3" {
    bucket = "ot-cloud-kit-bucket-2"
    key    = "ot/module/EKS/terraform.tfstate"
    region = "us-east-1"

  }
}