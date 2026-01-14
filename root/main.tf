module "eks" {
  source = "/home/ubuntu/new"

  # Project info
  bu      = var.bu
  program = var.program
  app     = var.app
  env     = var.env
  team    = var.team
  region  = var.region
  mission = var.mission

  # EKS Cluster
  eks_cluster_version      = var.eks_cluster_version
  endpoint_private_access  = var.endpoint_private_access
  endpoint_public_access   = var.endpoint_public_access
  private_subnet_ids       = var.private_subnet_ids

  # IAM
  eks_cluster_role_name        = var.eks_cluster_role_name
  eks_cluster_role_policy_arns = var.eks_cluster_role_policy_arns

  eks_node_role_name        = var.eks_node_role_name
  eks_node_role_policy_arns = var.eks_node_role_policy_arns

  # SG
  create_sg            = var.create_sg
  vpc_id               = var.vpc_id
  sg_names             = var.sg_names
  security_groups_rule = var.security_groups_rule
  eks_sg_rule          = var.eks_sg_rule

  ami_type  = var.ami_type
  key_pair  = var.key_pair
  node_groups = var.node_groups
}
