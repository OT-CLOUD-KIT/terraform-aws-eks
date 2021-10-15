locals {
  common_tags        = { ENV : "NON-PROD", OWNER : "DEVOPS", PROJECT : "EKS_CLUSTER", COMPONENT : "BUILDPIPER" }
  worker_group1_tags = { "name" : "worker01" }
  worker_group2_tags = { "name" : "worker02" }
  worker_group3_tags = { "name" : "worker03" }
}

module "eks_internal_ssh_security_group" {
  source  = "OT-CLOUD-KIT/security-groups/aws"
  version = "1.0.0"
  enable_whitelist_ip = true
  name_sg             = "Whitelist ssh Security Group"
  vpc_id              = var.vpc_id
  ingress_rule = {
    rules = {
      rule_list = [
        {
          description  = "443 port for Opstree Team"
          from_port    = 22
          to_port      = 22
          protocol     = "tcp"
          cidr         = ["103.100.4.78/32", "180.94.32.9/32"]
          source_SG_ID = []
        }
      ]
    }
  }
}

module "eks_cluster" {
  source                       = "../../../modules/eks"
  cluster_name                 = var.cluster_name
  eks_cluster_version          = "1.16"
  subnets                      = concat(var.private_subnet_id, var.public_subnet_id)
  tags                         = local.common_tags
  kubeconfig_name              = "config"
  config_output_path           = "config"
  eks_node_group_name          = "non-prod-eks-cluster"
  region                       = "ap-southeast-1"
  cluster_endpoint_whitelist   = true
  cluster_endpoint_access_cidrs = ["127.0.0.1/32"]
  create_node_group            = true
  endpoint_private             = true
  endpoint_public              = false
  k8s-spot-termination-handler = false
  cluster_autoscaler           = false
  metrics_server               = false
  vpc_id                       = var.vpc_id
  slackUrl                     = "slack_webhook_url"
  node_groups = {
    "worker1" = {
      subnets            = var.private_subnet_id
      ssh_key            = var.ssh_key
      security_group_ids = [module.eks_internal_ssh_security_group.sg_id]
      instance_type      = ["m5a.xlarge"]
      desired_capacity   = 2
      disk_size          = 100
      max_capacity       = 15
      min_capacity       = 2
      capacity_type      = "SPOT"
      tags               = merge(local.common_tags, local.worker_group1_tags)
      labels             = { "TYPE" : "MEMORY", "PROJECT" : "BUILDPIPER" }
    }
    "worker2" = {
      subnets            = var.private_subnet_id
      ssh_key            = var.ssh_key
      security_group_ids = [module.eks_internal_ssh_security_group.sg_id]
      instance_type      = ["c5.xlarge"]
      desired_capacity   = 2
      disk_size          = 100
      max_capacity       = 15
      min_capacity       = 2
      capacity_type      = "SPOT"
      tags               = merge(local.common_tags, local.worker_group2_tags)
      labels             = { "TYPE" : "CPU", "PROJECT" : "BUILDPIPER" }
    }
    "worker3" = {
      subnets            = var.private_subnet_id
      ssh_key            = var.ssh_key
      security_group_ids = [module.eks_internal_ssh_security_group.sg_id]
      instance_type      = ["m5a.xlarge"]
      desired_capacity   = 2
      disk_size          = 100
      max_capacity       = 15
      min_capacity       = 2
      capacity_type      = "ON_DEMAND"
      tags               = merge(local.common_tags, local.worker_group3_tags)
      labels             = { "TYPE" : "ON-DEMAND", "PROJECT" : "BUILDPIPER" }
    }
  }
}
