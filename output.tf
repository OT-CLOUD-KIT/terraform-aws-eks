output "endpoint" {
  description = "Endpoint for EKS cluster"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_iam_role_arn" {
  description = "Cluster IAM Role ARN"
  value       = aws_iam_role.cluster_role.arn
}

output "kubeconfig-certificate-authority-data" {
  description = "Kubernetes SSL certificate data"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.eks_cluster.id
}

output "eks_cluster_arn" {
  description = "EKS resource ARN"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "eks_security_group_id" {
  description = "SG ID"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id

}

####################
#### Node Group ####
####################

output "node_group_arn" {
  description = "ARN of node group"
  value = {
    for node_group in aws_eks_node_group.node_groups :
    node_group.id => node_group.arn
  }
}

output "node_group_resources" {
  description = "Resources created for node group"
  value = {
    for node_group in aws_eks_node_group.node_groups :
    node_group.id => node_group.resources
  }
}

output "node_iam_role_arn" {
  description = "Worker nodes IAM Role ARN"
  value       = aws_iam_role.node_group_role
}

output "launch_template" {
  value = { for k, v in aws_launch_template.launch_template : k => v.id }
}

output "aws_security_group" {
  value = aws_security_group.worker-SG.id
}

###############
### Fargate ###
###############

output "aws_eks_fargate_profile" {
  value = {for k, v in aws_eks_fargate_profile.fargate : k => v.id}
}

output "aws_iam_role" {
  value = aws_iam_role.fargate_role
}

#############
#### KMS ####
#############

output "aws_kms_key" {
  value = aws_kms_key.eks_cluster.arn
}