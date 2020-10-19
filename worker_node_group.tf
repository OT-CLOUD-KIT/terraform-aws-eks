# data "aws_ami" "eks-worker" {
#    filter {
#      name   = "name"
#      values = ["amazon-eks-node-${var.eks_cluster_version}*"]
#    }
#    most_recent = true
#    owners      = ["self"] # Amazon EKS AMI Account ID
#  }

# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks_cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks_cluster.certificate_authority[0].data}' '${var.cluster_name}'
USERDATA
}

resource "aws_iam_instance_profile" "worker_role_profile" {
  name = "EKS_WORKER_ROLE_TEST"
  role = aws_iam_role.node_group_role.name
}

resource "aws_launch_configuration" "worker_instance" {
  for_each                    = var.create_spot_node_group ? var.spot_node_group : {}
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.worker_role_profile.name
  # image_id                    = data.aws_ami.eks-worker.id
  image_id                    = each.value.ami_id
  instance_type               = each.value.instance_type
  spot_price                  = each.value.spot_price
  key_name                    = each.value.ssh_key
  name_prefix                 = substr(each.key, 0, 12)
  security_groups             = [aws_security_group.worker-node.id]
  user_data_base64            = base64encode(local.node-userdata)
  root_block_device {
    encrypted   = false
    volume_size = each.value.disk_size
    volume_type = "gp2"
    delete_on_termination = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "node_autoscaling_group" {
  for_each             = var.create_spot_node_group ? var.spot_node_group : {}
  desired_capacity     = each.value.desired_capacity
  #launch_configuration = aws_launch_configuration.worker_instance.id
  launch_configuration = aws_launch_configuration.worker_instance[each.key].id
  max_size             = each.value.max_capacity
  min_size             = each.value.min_capacity
  name                 = substr(each.key, 0, 12)
  vpc_zone_identifier = each.value.subnets
  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
  mixed_instances_policy instances_distribution {
    spot_instance_pools  = each.value.spot_instance_pools
    spot_max_price       = each.value.spot_max_price  
  }
}
