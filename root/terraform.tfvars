region = "us-east-1"

vpc_id = "vpc-077a18d7e699549b5"

private_subnet_ids = [
  "subnet-0fc9c1ac68aa06226",
  "subnet-09c411cd990ce3790"
]

key_pair = "new"

bu      = "NEW"
program = "OT"
app     = "database"
env     = "p"
team    = "infra"
mission = "infra-core"

eks_cluster_version = "1.29"

endpoint_private_access = true
endpoint_public_access  = false

############################################
# IAM Role Names (FIX for empty name error)
############################################
eks_cluster_role_name = "BP-p-OT-database-eks-cluster-role"
eks_node_role_name    = "BP-p-OT-database-eks-node-role"

############################################
# IAM Policy ARNs
############################################
eks_cluster_role_policy_arns = {
  eks_cluster = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

eks_node_role_policy_arns = {
  eks_worker_node = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  eks_cni         = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ec2_readonly    = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

############################################
# Security Groups
############################################
sg_names = ["app", "db"]

security_groups_rule = {
  app = {
    name = "app"

    ingress_rules = [
      {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        description     = "HTTP"
        cidr_blocks     = ["10.0.0.0/8"]
        source_sg_names = []
      }
    ]

    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        description = "all"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }

  db = {
    name = "db"

    ingress_rules = [
      {
        from_port       = 5432
        to_port         = 5432
        protocol        = "tcp"
        description     = "Postgres"
        cidr_blocks     = ["10.0.0.0/8"]
        source_sg_names = []
      }
    ]

    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        description = "all"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}

############################################
# allow worker SG -> cluster SG port 443
############################################
eks_sg_rule = [
  {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
  }
]

############################################
# Node Groups (FIXED structure)
############################################
ami_type = "AL2_x86_64"

node_groups = {
  app = {
    subnet_ids          = ["subnet-0fc9c1ac68aa06226"]
    capacity_type       = "ON_DEMAND"
    instance_type       = "t3.micro"
    associate_public_ip = false

    scaling_config = {
      desired_size = 1
      min_size     = 1
      max_size     = 2
    }

    ebs = {
      volume_size           = 30
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }

    taint = {
      key    = "app"
      value  = "true"
      effect = "NO_SCHEDULE"
    }

    sg_names = ["app"]

    labels = {
      role = "app"
    }
  }

  db = {
    subnet_ids          = ["subnet-09c411cd990ce3790"]
    capacity_type       = "ON_DEMAND"
    instance_type       = "t3.micro"
    associate_public_ip = false

    scaling_config = {
      desired_size = 1
      min_size     = 1
      max_size     = 2
    }

    ebs = {
      volume_size           = 30
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }

    taint = {
      key    = "db"
      value  = "true"
      effect = "NO_SCHEDULE"
    }

    sg_names = ["db"]

    labels = {
      role = "db"
    }
  }
}
