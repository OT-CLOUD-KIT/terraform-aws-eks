provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}

locals {
  common_tags = { ENV : "QA", OWNER : "DEVOPS", PROJECT : "CATALOG_MIGRATION", COMPONENT : "EKS", COMPONENT_TYPE : "BUILDPIPER" }
  worker_group1_tags = { "name": "worker01" }
  worker_group2_tags = { "name": "worker02" }
}

module "petpark_eks_cluster" {
  source                 =  "../eks"
  cluster_name           =  var.cluster_name
  eks_cluster_version    =  "1.16"
  subnets                =  ["subnet-057a78d8d14adf40c", "subnet-0ac0f6a4d0c41eecc"]
  tags                   =  local.common_tags
  kubeconfig_name        =  "config"
  config_output_path     =  "config"
  eks_node_group_name    =  "test-eks-cluster"
  region                 =  "ap-south-1"
  endpoint_private       =  false
  endpoint_public        =  true
  create_spot_node_group =  true
  create_node_group      =  false
  vpc_id              =  "vpc-077a88f9398c12b39"
  slackUrl	          =  "https://hooks.slack.com/services/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"  
  node_groups = {}
 spot_node_group = {
	"spot_worker1" = {
	  subnets             = ["subnet-057a78d8d14adf40c", "subnet-0ac0f6a4d0c41eecc"]
	  instance_type       =   "m5a.2xlarge"
    ami_id              = "ami-xyz"
	  disk_size           = 40
    desired_capacity    = 2
	  max_capacity        = 6
    min_capacity        = 2
    ssh_key             = var.ssh_key
    spot_price          = "1.117"
	  security_group_ids  = ["sg-0793542c5c6998159"]
	  tags                = merge(local.common_tags, local.worker_group1_tags)
  	}
  }
}
