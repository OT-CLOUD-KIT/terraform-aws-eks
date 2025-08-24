output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = module.eks.eks_cluster_arn
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.eks.eks_cluster_endpoint
}
output "eks_cluster_sg" {
  value = module.eks.eks_cluster_sg
}

###################### Outputs for Node Group ####################

output "eks_node_group_app" {
  description = "The name of the EKS node group"
  value       = module.eks.eks_node_group_app
}

output "eks_node_group_db" {
  description = "The name of the EKS node group"
  value       = module.eks.eks_node_group_app
}

output "eks_node_group_role_arn" {
  description = "The ARN of the node group role"
  value       = module.eks.eks_node_group_role_arn
}