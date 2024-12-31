
# Output the ARN of the EKS Node Group Role
output "node_group_role_arn" {
  value       = module.eks.node_role_arn
  description = "ARN of the IAM role associated with the EKS node group."
}