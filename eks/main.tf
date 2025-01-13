resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = var.cluster_role

  vpc_config {
    subnet_ids              = [for subnet_id in var.subnet_ids : subnet_id]
    endpoint_public_access  = var.enable_public_endpoint
    endpoint_private_access = !var.enable_public_endpoint
  }

  access_config {
    authentication_mode                         = var.authentication_mode ? "API_AND_CONFIG_MAP" : "CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
}

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  client_id_list = ["sts.amazonaws.com"]
  url = aws_eks_cluster.eks.identity.0.oidc.0.issuer
}

locals {
  cluster_dns_ip = cidrhost(aws_eks_cluster.eks.kubernetes_network_config[0].service_ipv4_cidr, 10)
}

resource "aws_security_group" "node_group_sg" {
  name        = "${var.cluster_name}-node-group-sg"
  vpc_id      = var.vpc_id
  description = "Security group for EKS node group that allows traffic from the EKS cluster"

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp" # Changed from 'https' to 'tcp'
    security_groups = [aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id]
    description     = "Allow inbound traffic from EKS cluster security group"
  }

  dynamic "ingress" {
    for_each = var.eks_ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = var.eks_egress
    content {
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
      description      = egress.value.description
    }
  }

  tags = {
    Name = "${var.cluster_name}-node-group-sg"
  }
}

resource "aws_security_group_rule" "eks_cluster_sg_rule" {
  for_each                 = var.eks_cluster_sg_rules
  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = "tcp"
  source_security_group_id = each.value.source_security_group_id
  security_group_id        = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}

resource "aws_launch_template" "eks_node_template" {
  count         = length(var.node_groups)
  name          = "${var.node_groups[count.index].name}-launch-template"
  instance_type = var.node_groups[count.index].instance_type
  image_id      = var.node_image_id //data.aws_ami.eks_worker.id
  key_name      = var.key_pair

  user_data = base64encode(<<-EOF
    MIME-Version: 1.0
    Content-Type: multipart/mixed; boundary="//"

    --//
    Content-Type: text/x-shellscript; charset="us-ascii"
    #!/bin/bash
    sudo su
    set -ex

    /etc/eks/bootstrap.sh '${var.cluster_name}' \
    --b64-cluster-ca "${aws_eks_cluster.eks.certificate_authority[0].data}" \
    --apiserver-endpoint "${aws_eks_cluster.eks.endpoint}" \
    --dns-cluster-ip "${local.cluster_dns_ip}" \
    --kubelet-extra-args '${var.node_groups[count.index].kubelet_extra_args}' \
    --use-max-pods false
  EOF
  )

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.node_groups[count.index].volume_size
      volume_type = "gp3"
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.node_group_sg.id, aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id]
  }

  dynamic "instance_market_options" {
    for_each = var.node_groups[count.index].capacity_type == "spot" ? [1] : []
    content {
      market_type = "spot"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = coalesce(var.node_groups[count.index].tag_name, "${var.env}-app-k8s-${var.node_groups[count.index].name}")
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = coalesce(var.node_groups[count.index].tag_name, "${var.env}-app-k8s-${var.node_groups[count.index].name}")
    }
  }

}

resource "aws_eks_node_group" "node_group" {
  count           = length(var.node_groups)
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_groups[count.index].name
  node_role_arn   = var.node_role
  subnet_ids      = [for subnet_id in var.subnet_ids : subnet_id]

  scaling_config {
    desired_size = var.node_groups[count.index].desired_size
    max_size     = var.node_groups[count.index].max_size
    min_size     = var.node_groups[count.index].min_size
  }

  labels = var.node_groups[count.index].labels

  dynamic "taint" {
    for_each = var.node_groups[count.index].taint != null ? var.node_groups[count.index].taint : []
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  capacity_type = var.node_groups[count.index].capacity_type

  launch_template {
    id      = aws_launch_template.eks_node_template[count.index].id
    version = aws_launch_template.eks_node_template[count.index].latest_version
  }
}

resource "aws_eks_addon" "addons" {
  count         = length(var.eks_addons)
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = var.eks_addons[count.index].name
  addon_version = var.eks_addons[count.index].version

  tags = {
    Name        = "${var.cluster_name}-${var.eks_addons[count.index].name}-addon"
    Provisioner = "Terraform"
  }

  depends_on = [aws_eks_cluster.eks, aws_eks_node_group.node_group]
}

