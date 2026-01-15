module "eks" {
  source = "../"

  ############################################
  # Project / Tagging Information
  # Used for naming conventions and resource tags
  ############################################
  bu      = var.bu
  program = var.program
  app     = var.app
  env     = var.env
  team    = var.team
  region  = var.region
  mission = var.mission

  ############################################
  # EKS Cluster Configuration
  # - eks_cluster_version: Kubernetes version
  # - endpoint_*: API endpoint access control (public/private)
  # - private_subnet_ids: subnets used for EKS control plane networking
  ############################################
  eks_cluster_version     = var.eks_cluster_version
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  private_subnet_ids      = var.private_subnet_ids

  ############################################
  # IAM Configuration
  # Cluster role is required for EKS control plane operations
  # Node role is required for worker nodes to join the cluster and access AWS services
  ############################################
  eks_cluster_role_name        = var.eks_cluster_role_name
  eks_cluster_role_policy_arns = var.eks_cluster_role_policy_arns

  eks_node_role_name        = var.eks_node_role_name
  eks_node_role_policy_arns = var.eks_node_role_policy_arns

  ############################################
  # Security Group Configuration
  # - create_sg: enables/disables security group creation
  # - security_groups_rule: ingress/egress rules for worker node SGs
  # - eks_sg_rule: rules to allow node SGs to communicate with the EKS cluster SG
  ############################################
  create_sg            = var.create_sg
  vpc_id               = var.vpc_id
  sg_names             = var.sg_names
  security_groups_rule = var.security_groups_rule
  eks_sg_rule          = var.eks_sg_rule

  ############################################
  # Node Group Configuration
  # - ami_type: EKS node AMI type
  # - key_pair: optional SSH key pair for worker nodes
  # - node_groups: map of node groups (app/db/etc) including scaling and EBS settings
  ############################################
  ami_type    = var.ami_type
  key_pair    = var.key_pair
  node_groups = var.node_groups
}
