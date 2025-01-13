output "cluster_name" {
  value       = aws_eks_cluster.eks.name
  description = "The name of the EKS cluster."
}
output "node_role_arn" {
  value       = var.node_role
  description = "ARN of the IAM role associated with the EKS node group."
}

output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.eks.endpoint
  description = "The endpoint of the EKS cluster."
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}
