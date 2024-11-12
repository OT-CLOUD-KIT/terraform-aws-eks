data "aws_vpc" "eks-vpc" {
    id = "vpc-082129ed7e8f98076"   
}
data "aws_subnet" "subnets" {
    count = length(var.cluster_subnets)
    filter {
        name = "tag:Name"
        values = [var.cluster_subnets[count.index]]
    }
}
data "aws_subnet" "private_subnets" {
    count = length(var.private_subnets)
    filter {
        name = "tag:Name"
        values = [var.private_subnets[count.index]]
    }
}

resource "aws_eks_cluster" "eks" {
  name     = var.cluster-name
  role_arn = var.cluster-role

  vpc_config {
    subnet_ids = [for subnet in data.aws_subnet.subnets : subnet.id]
  }
}
resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0b4dd9f6c"]
  url             = aws_eks_cluster.eks.identity.0.oidc.0.issuer
} 

data "aws_eks_cluster_auth" "eks_auth" {
  name = aws_eks_cluster.eks.name
}

# Launch Template
 data "aws_ami" "eks_worker" {
  most_recent = true
  owners      = ["602401143452"]  # AWS EKS AMI owner ID

  filter {
    name   = "name"
    values = ["amazon-eks-node-1.31-*"]  # Change to match your EKS version
  }
}

resource "aws_launch_template" "eks_node_template" { 
  count          = length(var.node_groups)
  name           = "${var.node_groups[count.index].name}-launch-template"
  instance_type  = var.node_groups[count.index].instance_type
  image_id       = data.aws_ami.eks_worker.id
  key_name       = "shivam" 
  user_data      = var.node_groups[count.index].user_data != null ? base64encode(file(var.node_groups[count.index].user_data)) : null

   block_device_mappings {
      device_name = "/dev/xvda"
      ebs {
        volume_size = var.node_groups[count.index].volume_size
        volume_type = "gp3"
      }
    }

    network_interfaces {
      associate_public_ip_address  = false
      security_groups              = var.node_groups[count.index].security_group
    }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.node_groups[count.index].name}-node"
    }
  }
}

resource "aws_eks_node_group" "node_group" {
  count = length(var.node_groups)

  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_groups[count.index].name
  node_role_arn   = var.node_role
  subnet_ids      = [for subnet in data.aws_subnet.private_subnets : subnet.id]

  scaling_config {
    desired_size = var.node_groups[count.index].desired_size
    max_size     = var.node_groups[count.index].max_size
    min_size     = var.node_groups[count.index].min_size
  }
  labels = var.node_groups[count.index].labels
 
  # Specify taints here
  dynamic "taint" {
    for_each = var.node_groups[count.index].taint != null ? var.node_groups[count.index].taint : []
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
  launch_template {
    id      = aws_launch_template.eks_node_template[count.index].id
    version = "$Latest"
  }
}
resource "aws_eks_addon" "addons" {
  count         = length(var.eks_addons)
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = var.eks_addons[count.index].name
  addon_version = var.eks_addons[count.index].version
  

  # Optional: define the service account role ARN if required
  # service_account_role_arn = var.addon_role_arn[var.eks_addons[count.index].name]

  tags = {
    Name        = "${var.cluster-name}-${var.eks_addons[count.index].name}-addon"
    Provisioner = "Terraform"
  } 

  depends_on = [aws_eks_cluster.eks]
}


# # Managed Node Group
# resource "aws_eks_node_group" "eks_node_group" {
#   cluster_name    = aws_eks_cluster.eks.name
#   node_group_name = "${var.cluster_name}-node-group"
#   node_role_arn   = module.iam_roles.iam_roles["${var.cluster_name}-eks-node-group-role"].arn
#   subnet_ids      = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

#   scaling_config {
#     desired_size = 2
#     max_size     = 3
#     min_size     = 1
#   }

#   launch_template {
#     id      = aws_launch_template.eks_node_template.id
#     version = "$Latest"
#   }

#   depends_on = [
#     aws_eks_cluster.eks
#   ]
# }

# resource "aws_launch_template" "eks-launch-template" {
#     count          = length(var.node_groups)
#     name           = "${var.node_groups[count.index].name}-launch-template"
#     instance_type  = var.node_groups[count.index].instance_type
#     user_data      = var.node_groups[count.index].user_data_file != null ? base64encode(file(var.node_groups[count.index].user_data_file)) : null

#     block_device_mappings {
#       device_name = "/dev/xvda"
#       ebs {
#         volume_size = var.node_groups[count.index].volume_size
#         volume_type = "gp2"
#       }
#     }

#     network_interfaces {
#       associate_public_ip_address  = false
#       security_groups              = var.node_groups[count.index].security_group
#     }

#     tag_specifications {
#       resource_type = "instance"
#       tags = {
#         Name = "${var.node_groups[count.index].name}-node"
#       }
#     }
# }

// node group for eks
