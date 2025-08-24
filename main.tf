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


  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]

  
    tags = merge(
    {
      Name = "${local.eks_name}"
    },
    local.common_tags
  )
}

resource "aws_iam_role" "eks_cluster_role" {
  name = var.eks_cluster_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  for_each   = var.eks_cluster_role_policy_arns
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = each.value
}

resource "aws_iam_role" "eks_node_role" {
  name = var.eks_node_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_role_attachments" {
  for_each   = var.eks_node_role_policy_arns
  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}


#################### Security Groups ########################

resource "aws_security_group" "sg" {
  for_each = var.create_sg ? local.security_group_config : {}

  name   = each.value.name
  vpc_id = var.vpc_id

  tags = {
    Name  = each.value.name
    env   = var.env
  }

  
  depends_on = [aws_eks_cluster.eks]
}

resource "aws_security_group_rule" "ingress" {
  for_each = var.create_sg ? {
    for idx, rule in local.flattened_ingress_rules :
    idx => rule if rule.rule_type == "cidr" || rule.rule_type == "sg"
  } : {}

  type              = var.sg_ingress_type
  from_port         = each.value.rule.from_port
  to_port           = each.value.rule.to_port
  protocol          = each.value.rule.protocol
  description       = each.value.rule.description
  security_group_id = aws_security_group.sg[each.value.sg_name].id

  cidr_blocks = each.value.rule_type == "cidr" ? each.value.rule.cidr_blocks : null
  source_security_group_id = each.value.rule_type == "sg" ? (
    try(local.known_source_sgs[each.value.rule.source_sg_names[0]], aws_security_group.sg[each.value.rule.source_sg_names[0]].id)
  ) : null


  depends_on = [
    aws_security_group.sg
  ]
}

resource "aws_security_group_rule" "egress" {
  for_each = var.create_sg ? {
    for idx, rule in local.flattened_egress_rules :
    idx => rule if rule.rule_type == "cidr" || rule.rule_type == "sg"
  } : {}

  type              = var.sg_egress_type
  from_port         = each.value.rule.from_port
  to_port           = each.value.rule.to_port
  protocol          = each.value.rule.protocol
  description       = each.value.rule.description
  security_group_id = aws_security_group.sg[each.value.sg_name].id

  cidr_blocks              = each.value.rule_type == "cidr" ? each.value.rule.cidr_blocks : null
  source_security_group_id = each.value.rule_type == "sg" ? aws_security_group.sg[each.value.source_sg_names[0]].id : null

  depends_on = [
    aws_security_group.sg
  ]
}




resource "aws_security_group_rule" "sg_to_eks_ingress" {
  for_each = { for rule in local.eks_sg_rules_flat : rule.key => rule }

  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = each.value.source_sg_id
  security_group_id        = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id

  description = "Allow ${each.key} SG to access EKS Cluster"
}


###################### APP Node Group  ####################

resource "aws_launch_template" "eks_app_launch_template" {
  name_prefix   = local.app_lt_name
  key_name      = var.key_pair != "" ? var.key_pair : null
  instance_type = var.app_instance_type


  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_app
    security_groups             = local.app_lt_sg
  }


  tag_specifications {
    resource_type = "instance"
    # tags = {
    #   Name  = "${local.node_group_name}-app"
    #   env   = var.env
    #   owner = var.owner
    # }
      tags = merge(
    {
      Name = "${local.node_group_name}-app"
    },
    local.common_tags
  )
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.ebs_app_volume_size
      volume_type           = var.ebs_app_volume_type
      delete_on_termination = var.delete_on_termination_app
      encrypted             = var.app_encrypted
    }
  }


    tags = merge(
    {
      Name = "${local.node_group_name}-app"
    },
    local.common_tags
  )
  depends_on = [aws_security_group.sg]
}



resource "aws_eks_node_group" "app_node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${local.node_group_name}-app"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.application_subnet_ids

  ami_type      = var.ami_type
  capacity_type = var.app_capacity_type

  launch_template {
    id      = aws_launch_template.eks_app_launch_template.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = var.node_group_app_desired_size
    max_size     = var.node_group_app_max_size
    min_size     = var.node_group_app_min_size
  }

  labels = {
    "Name" = "${local.node_group_name}-app"
  }

  taint {
    key    = var.app_taint_key
    value  = var.app_taint_value
    effect = var.app_taint_effect
  }

 

    tags = merge(
    {
      Name = "${local.node_group_name}-app"
    },
    local.common_tags
  )
}


###################### DB Node Group  ####################

resource "aws_launch_template" "eks_db_launch_template" {
  name_prefix   = local.db_lt_name
  key_name      = var.key_pair != "" ? var.key_pair : null
  instance_type = var.db_instance_type


  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_db
    security_groups             = local.db_lt_sg
  }


  tag_specifications {
    resource_type = "instance"
  

      tags = merge(
    {
      Name = "${local.node_group_name}-db"
    },
    local.common_tags
  )
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.ebs_db_volume_size
      volume_type           = var.ebs_db_volume_type
      delete_on_termination = var.delete_on_termination_db
      encrypted             = var.db_encrypted
    }
  }


    tags = merge(
    {
      Name = "${local.node_group_name}-db"
    },
    local.common_tags
  )
  depends_on = [aws_security_group.sg]
}



resource "aws_eks_node_group" "db_node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${local.node_group_name}-db"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.database_subnet_ids

  ami_type      = var.ami_type
  capacity_type = var.db_capacity_type

  launch_template {
    id      = aws_launch_template.eks_db_launch_template.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = var.node_group_db_desired_size
    max_size     = var.node_group_db_max_size
    min_size     = var.node_group_db_min_size
  }

  labels = {
    "Name" = "${local.node_group_name}-db"
  }

  taint {
    key    = var.db_taint_key
    value  = var.db_taint_value
    effect = var.db_taint_effect
  }

  

    tags = merge(
    {
      Name = "${local.node_group_name}-db"
    },
    local.common_tags
  )
  depends_on = [aws_security_group.sg]
}
