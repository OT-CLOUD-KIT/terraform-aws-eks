data "terraform_remote_state" "bastion" {
  backend = "s3"
  config = {
    bucket = "ecomexp-dr-tf-state"
    key    = "dr/bastion.tfstate"
    region = "ap-south-1"
  }
}

terraform {
  backend "s3" {
    bucket  = "ecomexp-dr-tf-state"
    key     = "dr/eks.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}


