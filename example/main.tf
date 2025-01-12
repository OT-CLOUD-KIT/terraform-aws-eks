module "iam" {
  source         = "../iam"
  roles          = var.roles
  cluster_policy = var.cluster_policy
  node_policy    = var.node_policy
}

module "eks" {
  source                    = "../eks"
  env                       = var.env
  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnet_ids
  cluster_subnets           = var.cluster_subnets
  cluster_name              = var.cluster_name
  cluster-role              = module.iam.eks-roles[0]
  node_groups               = var.node_groups
  key_pair                  = var.key_pair
  node_image_id             = var.node_image_id 
  # private_subnets           = var.private_subnets
  node_role                 = module.iam.eks-roles[1]
  eks_addons                = var.eks_addons
  eks_ingress               = var.eks_ingress
  eks_egress                = var.eks_egress
  enable_public_endpoint    = var.enable_public_endpoint
  authentication_mode       = var.authentication_mode
  enable_cluster_autoscaler = var.enable_cluster_autoscaler
  aws_region                = var.aws_region
  eks_cluster_sg_rules       = var.eks_cluster_sg_rules
}
