output "endpoint" {
  description = "Endpoint for EKS cluster"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "node_iam_role_arn" {
  description = "Worker nodes IAM Role ARN"
  value       = aws_iam_role.node_group_role.arn
}

output "cluster_iam_role_arn" {
  description = "Cluster IAM Role ARN"
  value       = aws_iam_role.cluster_role.arn
}

output "node_groups_arn" {
  description = "Worker nodes resource ARN"
  value       = module.node_group.node_group_arn
}

output "node_groups_resources" {
  description = "Cluster resource ARN"
  value       = module.node_group.node_group_resources
}

output "kubeconfig-certificate-authority-data" {
  description = "Kubernetes SSL certificate data"
  value       = aws_eks_cluster.eks_cluster.certificate_authority.0.data
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.eks_cluster.id
}

output "eks_cluster_arn" {
  description = "EKS resource ARN"
  value       = aws_eks_cluster.eks_cluster.arn
}
