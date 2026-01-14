output "eks_cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "eks_cluster_sg_id" {
  value = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}

output "node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}
