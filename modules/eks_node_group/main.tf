resource "aws_eks_node_group" "node_groups" {
  for_each     = var.create_node_group ? var.node_groups : {}
  cluster_name = var.cluster_name
  tags = merge(
    {
      Name = format("%s-node_group", substr(each.key, 0, 12))
    },
    {
      "Provisioner" = "Terraform"
    },
    each.value.tags
  )
  node_group_name = substr(each.key, 0, 12)
  node_role_arn   = var.node_role_arn
  subnet_ids      = each.value.subnets
  instance_types  = each.value.instance_type
  disk_size       = each.value.disk_size
  labels          = each.value.labels

  scaling_config {
    desired_size = each.value.desired_capacity
    max_size     = each.value.max_capacity
    min_size     = each.value.min_capacity
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes        = [scaling_config.0.desired_size]
  }

  remote_access {
    ec2_ssh_key               = each.value.ssh_key
    source_security_group_ids = each.value.security_group_ids
  }
}
