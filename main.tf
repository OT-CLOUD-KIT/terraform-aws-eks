module "iam" {
    source = "./modules/iam"
    roles  = var.roles
    cluster-policy = var.cluster-policy
    node-policy    = var.node-policy
}
module "eks" {
    source = "./modules/eks"
    depends_on = [module.iam]
    cluster_subnets = var.cluster_subnets
    cluster-name = var.cluster-name
    cluster-role = module.iam.eks-roles[0]
    node_groups  = var.node_groups
    private_subnets = var.private_subnets
    node_role = module.iam.eks-roles[1]
    eks_addons = var.eks_addons
    eks_ingress = var.eks_ingress
    eks_egress = var.eks_egress
}