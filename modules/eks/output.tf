output "cluster_name" {
  value       = aws_eks_cluster.eks.name
  description = "The name of the EKS cluster."
}
output "node_role_arn" {
  value       = var.node_role
  description = "ARN of the IAM role associated with the EKS node group."
}
output "vpc_id" {
  value       = data.aws_vpc.eks-vpc.id
  description = "The ID of the VPC used for the EKS cluster."
}