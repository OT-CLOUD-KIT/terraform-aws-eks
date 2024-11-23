data "aws_vpc" "eks-vpc" {
  id = "vpc-082129ed7e8f98076"
}

data "aws_subnet" "subnets" {
  count = length(var.cluster_subnets)
  filter {
    name   = "tag:Name"
    values = [var.cluster_subnets[count.index]]
  }
}

data "aws_subnet" "private_subnets" {
  count = length(var.private_subnets)
  filter {
    name   = "tag:Name"
    values = [var.private_subnets[count.index]]
  }
}

resource "aws_eks_cluster" "eks" {
  name     = var.cluster-name
  role_arn = var.cluster-role

  vpc_config {
    subnet_ids                = [for subnet in data.aws_subnet.subnets : subnet.id]
    endpoint_public_access    = var.enable_public_endpoint
    endpoint_private_access   = !var.enable_public_endpoint
  }

  access_config {
  authentication_mode = var.authentication_mode ? "API_AND_CONFIG_MAP" : "CONFIG_MAP"
  bootstrap_cluster_creator_admin_permissions = true
  }
}

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0b4dd9f6c"]
  url             = aws_eks_cluster.eks.identity.0.oidc.0.issuer
}

data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = aws_eks_cluster.eks.name
}

data "aws_ami" "eks_worker" {
  most_recent = true
  owners      = ["602401143452"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-1.31-*"]
  }
}

resource "aws_security_group" "node_group_sg" {
  name        = "${var.cluster-name}-node-group-sg"
  vpc_id      = data.aws_vpc.eks-vpc.id
  description = "Security group for EKS node group that allows traffic from the EKS cluster"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [data.aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id]
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
    Name = "${var.cluster-name}-node-group-sg"
  }
}

resource "aws_launch_template" "eks_node_template" {
  count         = length(var.node_groups)
  name          = "${var.node_groups[count.index].name}-launch-template"
  instance_type = var.node_groups[count.index].instance_type
  image_id      = data.aws_ami.eks_worker.id
  key_name      = "shivam"

  user_data = base64encode(<<-EOF
    MIME-Version: 1.0
    Content-Type: multipart/mixed; boundary="//"

    --//
    Content-Type: text/x-shellscript; charset="us-ascii"
    #!/bin/bash
    sudo su
    set -ex

    /etc/eks/bootstrap.sh "OT-microservices" \
    --b64-cluster-ca "${data.aws_eks_cluster.eks.certificate_authority[0].data}" \
    --apiserver-endpoint "${data.aws_eks_cluster.eks.endpoint}" \
    --dns-cluster-ip "172.20.0.10" \
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
    for_each = var.capacity_type == "SPOT" ? [1] : []
    content {
      market_type = "spot"
      #spot_price  = var.spot_price  # Using the spot price variable
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.node_groups[count.index].name}-node"
    }
  }
}

resource "aws_eks_node_group" "node_group" {
  count           = length(var.node_groups)
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

  dynamic "taint" {
    for_each = var.node_groups[count.index].taint != null ? var.node_groups[count.index].taint : []
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  capacity_type = var.capacity_type

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
    Name        = "${var.cluster-name}-${var.eks_addons[count.index].name}-addon"
    Provisioner = "Terraform"
  }

  depends_on = [aws_eks_cluster.eks]
}