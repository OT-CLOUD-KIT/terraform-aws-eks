###################### EKS Cluster  ####################

resource "aws_eks_cluster" "eks" {
  name     = local.eks_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_cluster_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_role_attachments]

  tags = merge(
    { Name = local.eks_name },
    local.common_tags
  )
}

###################### IAM Roles ####################

resource "aws_iam_role" "eks_cluster_role" {
  name = var.eks_cluster_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = ["sts:AssumeRole"]
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_role_attachments" {
  for_each   = var.eks_cluster_role_policy_arns
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = each.value
}

resource "aws_iam_role" "eks_node_role" {
  name = var.eks_node_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_role_attachments" {
  for_each   = var.eks_node_role_policy_arns
  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}

#################### Security Groups ########################

resource "aws_security_group" "sg" {
  for_each = var.create_sg ? local.security_group_config : {}

  name   = each.value.name
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name = each.value.name
    },
    local.common_tags
  )

  depends_on = [aws_eks_cluster.eks]
}

resource "aws_security_group_rule" "ingress" {
  for_each = var.create_sg ? {
    for idx, rule in local.flattened_ingress_rules :
    idx => rule if rule.rule_type == "cidr" || rule.rule_type == "sg"
  } : {}

  type              = "ingress"
  from_port         = each.value.rule.from_port
  to_port           = each.value.rule.to_port
  protocol          = each.value.rule.protocol
  description       = each.value.rule.description
  security_group_id = aws_security_group.sg[each.value.sg_name].id

  cidr_blocks = each.value.rule_type == "cidr" ? each.value.rule.cidr_blocks : null

  source_security_group_id = each.value.rule_type == "sg" ? (
    try(
      aws_security_group.sg[each.value.rule.source_sg_names[0]].id,
      null
    )
  ) : null

  depends_on = [aws_security_group.sg]
}

resource "aws_security_group_rule" "egress" {
  for_each = var.create_sg ? {
    for idx, rule in local.flattened_egress_rules :
    idx => rule if rule.rule_type == "cidr" || rule.rule_type == "sg"
  } : {}

  type              = "egress"
  from_port         = each.value.rule.from_port
  to_port           = each.value.rule.to_port
  protocol          = each.value.rule.protocol
  description       = each.value.rule.description
  security_group_id = aws_security_group.sg[each.value.sg_name].id

  cidr_blocks = each.value.rule.cidr_blocks

  depends_on = [aws_security_group.sg]
}

###################### Launch Templates (Dynamic) ####################

resource "aws_launch_template" "node_lt" {
  for_each = var.node_groups

  name_prefix   = "${local.node_group_name}-${each.key}-lt"
  key_name      = var.key_pair != "" ? var.key_pair : null
  instance_type = each.value.instance_type

  network_interfaces {
    associate_public_ip_address = each.value.associate_public_ip
    security_groups = concat(
      [aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id],
      [for sgname in each.value.sg_names : aws_security_group.sg[sgname].id]
    )
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = each.value.ebs.volume_size
      volume_type           = each.value.ebs.volume_type
      delete_on_termination = each.value.ebs.delete_on_termination
      encrypted             = each.value.ebs.encrypted
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      { Name = "${local.node_group_name}-${each.key}" },
      local.common_tags
    )
  }

  tags = merge(
    { Name = "${local.node_group_name}-${each.key}-lt" },
    local.common_tags
  )

  depends_on = [aws_security_group.sg]
}

###################### Node Groups (Dynamic) ####################

resource "aws_eks_node_group" "node_group" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${local.node_group_name}-${each.key}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = each.value.subnet_ids

  ami_type      = var.ami_type
  capacity_type = each.value.capacity_type

  launch_template {
    id      = aws_launch_template.node_lt[each.key].id
    version = "$Latest"
  }

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    min_size     = each.value.scaling_config.min_size
    max_size     = each.value.scaling_config.max_size
  }

  labels = merge(
    { "Name" = "${local.node_group_name}-${each.key}" },
    each.value.labels
  )

  taint {
    key    = each.value.taint.key
    value  = each.value.taint.value
    effect = each.value.taint.effect
  }

  tags = merge(
    { Name = "${local.node_group_name}-${each.key}" },
    local.common_tags
  )

  depends_on = [aws_launch_template.node_lt]
}
