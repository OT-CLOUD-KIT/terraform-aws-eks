resource "aws_eks_node_group" "node_groups" {
  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
  for_each     = var.create_node_group ? var.node_groups : {}
  cluster_name = aws_eks_cluster.eks_cluster.name
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
  node_role_arn   = aws_iam_role.node_group_role[0].arn
  subnet_ids      = each.value.subnets
  instance_types  = each.value.instance_type
  labels               = each.value.labels
  capacity_type        = each.value.capacity_type
  force_update_version = var.force_update_version
  launch_template {
    id = aws_launch_template.launch_template[each.key].id
    version = aws_launch_template.launch_template[each.key].latest_version
  }

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
}


resource "aws_iam_role" "node_group_role" {
  count = var.create_node_group_role ? 1 : 0
  name = var.eks_node_group_name

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  tags = merge(
    {
      Name = format("%s-node_group_iam_role", var.eks_node_group_name)
    },
    {
      "Provisioner" = "Terraform"
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2FullAccess" {
  count = var.create_node_group_role ? 1 : 0  
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.node_group_role[0].name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  count = var.create_node_group_role ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_role[0].name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  count = var.create_node_group_role ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role[0].name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role[0].name
}

###################################
### Launch Template for workers ###
###################################

resource "aws_launch_template" "launch_template" {
  for_each = var.node_groups
  name     = "${each.key}-${aws_eks_cluster.eks_cluster.name}-LaunchTemplate"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = each.value.launch_template.volume_size
      encrypted   = var.encrypted
    }
  }

  image_id = each.value.launch_template.image_id
  key_name               = aws_key_pair.EKS_cluster_key[0].id
  vpc_security_group_ids = [aws_security_group.worker-SG.id]
  monitoring {
    enabled = true
  }

  #user_data = "${base64encode(file("${var.file_path}"))}"
  user_data = "${base64encode(data.template_file.userdata[each.key].rendered)}"

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name = format("%s-%s-EKS", each.key, var.cluster_name)
      },
      {
        "Provisioner" = "Terraform"
      },
      var.tags
    )
  }
}

####################################################
### Security Group for workers comm with cluster ###
####################################################

resource "aws_security_group" "worker-SG" {                     
  name        = "${aws_eks_cluster.eks_cluster.name}-Worker-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Cluster Communication"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups  = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]
  }

  ingress {
    description      = "Cluster Communication"
    from_port        = 10250
    to_port          = 10250
    protocol         = "tcp"
    security_groups  = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]
  }  

  ingress {
    description      = "Cluster Communication"
    from_port        = 53
    to_port          = 53
    protocol         = "udp"
    security_groups  = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]
  }  

  ingress {
    description      = "Cluster Communication"
    from_port        = 53
    to_port          = 53
    protocol         = "tcp"
    security_groups  = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]
  }  

  ingress {
    description      = "Cluster Communication"
    from_port        = 9443
    to_port          = 9443
    protocol         = "tcp"
    security_groups  = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]
  }   

  ingress {
    description      = "Node to Node Communication"
    from_port        = 0
    to_port          = 0
    protocol         = -1
    self             = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }  

  tags = merge(
    {
      Name = format("%s-Worker-SG", var.cluster_name)
    },
    {
      "Provisioner" = "Terraform"
    },
    var.tags
  )
}

####################
###  Data Block  ###
####################

data "template_file" "userdata" {
  for_each = var.node_groups
  template = "${var.userdatafile == false ? file("${path.module}/bootstrap.sh") : format("%s%s", file("${path.module}/bootstrap.sh"), file("${path.module}/${var.userdata_path}"))}"

  vars = {
    CLUSTER_NAME   = var.cluster_name
    B64_CLUSTER_CA = aws_eks_cluster.eks_cluster.certificate_authority.0.data
    API_SERVER_URL = aws_eks_cluster.eks_cluster.endpoint
    KUBELET_ARGS   = each.value.kubeargs
  }
}


###############
### SSH KEY ###
###############

resource "aws_key_pair" "EKS_cluster_key" {
  count = var.create_key_pair ? 1 : 0

  key_name        = var.key_name
  key_name_prefix = var.key_name_prefix
  public_key      = var.public_key

  tags = var.tags
}