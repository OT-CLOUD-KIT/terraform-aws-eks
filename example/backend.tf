terraform {
  backend "s3" {
    bucket     = "okts-tree"
    key        = "non-prod/k8s-cluster/eks/terraform.tfstate"
    region     = "ap-southeast-1"
  }
}
