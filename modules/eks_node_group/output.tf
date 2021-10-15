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

# output "node_group_security_group_id" {
#   description = "remote_access_security_group_id created for node group"
#   value = {
#     for node_group in aws_eks_node_group.node_groups :
#     node_group.id => node_group.resources.remote_access_security_group_id
#   }
# }
