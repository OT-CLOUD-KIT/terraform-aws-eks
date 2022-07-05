resource "aws_eks_cluster" "eks_cluster" {
  name                      = var.cluster_name
  enabled_cluster_log_types = var.enabled_cluster_log_types
  role_arn                  = aws_iam_role.cluster_role.arn
  version                   = var.eks_cluster_version

  dynamic "encryption_config" {
    for_each = var.create_encryption_config ? var.cluster_encryption_config : {}

    content {
      provider {
        key_arn = aws_kms_key.eks_cluster.arn
      }
      resources = encryption_config.value.resources
    }
  }

  tags = merge(
    {
      Name = format("%s-cluster", var.cluster_name)
    },
    {
      "Provisioner" = "Terraform"
    },
    var.tags
  )
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSServicePolicy,
  ]

  vpc_config {
    subnet_ids              = var.subnets
    endpoint_private_access = var.endpoint_private
    endpoint_public_access  = var.endpoint_public
    security_group_ids      = var.securitygroups == [] ? null : var.securitygroups
  }
}

resource "aws_iam_role" "cluster_role" {
  name = var.cluster_name

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = merge(
    {
      Name = format("%s-cluster_iam_role", var.cluster_name)
    },
    {
      "Provisioner" = "Terraform"
    },
    var.tags
  )
}

#####################
### Cluster Roles ###
#####################

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster_role.name
}

###################
### Subnet Tags ###
###################s

resource "aws_ec2_tag" "add_tags_into_subnet" {
  count       = length(var.subnets)
  resource_id = var.subnets[count.index]
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

########################
### Cluster SG Rules ###
########################

resource "aws_security_group_rule" "cluster_private_access_internal" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  source_security_group_id = aws_security_group.worker-SG.id
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_security_group_rule" "cluster_private_access_internal1" {
  type        = "ingress"
  from_port   = 10250
  to_port     = 10250
  protocol    = "tcp"
  source_security_group_id = aws_security_group.worker-SG.id
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_security_group_rule" "cluster_private_access_internal2" {
  type        = "ingress"
  from_port   = 53
  to_port     = 53
  protocol    = "tcp"
  source_security_group_id = aws_security_group.worker-SG.id
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_security_group_rule" "cluster_private_access_internal3" {
  type        = "ingress"
  from_port   = 53
  to_port     = 53
  protocol    = "udp"
  source_security_group_id = aws_security_group.worker-SG.id
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}