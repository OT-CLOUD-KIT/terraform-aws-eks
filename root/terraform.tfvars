############################################
# AWS Region
# - Region where EKS cluster will be created
############################################
region = "us-east-1"

############################################
# Networking
# - VPC where EKS cluster and worker nodes will run
# - private_subnet_ids are for EKS control plane endpoint network
############################################
vpc_id = "vpc-077a18d7e699549b5"

private_subnet_ids = [
  "subnet-0fc9c1ac68aa06226",
  "subnet-09c411cd990ce3790"
]

############################################
# SSH Key Pair (Optional)
# - Used to SSH into worker nodes (if you want)
# - If you don’t need SSH, you can keep it "".
############################################
key_pair = "new"

############################################
# Project Naming / Tags (Used for naming + tagging)
# These values build resources like:
#   <bu>-<env>-<program>-<app>-eks-cluster
############################################
bu      = "NEW"
program = "OT"
app     = "database"
env     = "p"
team    = "infra"
mission = "infra-core"

############################################
# EKS Cluster Configuration
############################################
eks_cluster_version = "1.29"

############################################
# EKS Endpoint Access
# - endpoint_private_access = true  -> API works inside VPC only
# - endpoint_public_access  = true  -> API works from internet
#
# Recommended:
# Private only for production
# Public only temporarily for troubleshooting
############################################
endpoint_private_access = true
endpoint_public_access  = false

############################################
# IAM Role Names (Mandatory)
# These roles are required by AWS:
# - Cluster Role -> Used by EKS control plane
# - Node Role    -> Used by EC2 worker nodes
############################################
eks_cluster_role_name = "BP-p-OT-database-eks-cluster-role"
eks_node_role_name    = "BP-p-OT-database-eks-node-role"

############################################
# IAM Managed Policies (Mandatory)
# These are standard AWS EKS policies:
#
# Cluster Policy:
# - AmazonEKSClusterPolicy -> Allows EKS cluster management
#
# Node Policies:
# - AmazonEKSWorkerNodePolicy         -> Node join cluster
# - AmazonEKS_CNI_Policy              -> Networking (CNI)
# - AmazonEC2ContainerRegistryReadOnly -> Pull images from ECR
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
# Security Group Setup
# create_sg = true  -> Terraform will create SGs
# create_sg = false -> Terraform will NOT create SGs (optional)
############################################
create_sg = true

############################################
# SG keys (Mandatory  if create_sg=true)
# These keys are used for:
# - generating SG names
# - attaching SG to node groups
############################################
sg_names = ["app", "db"]

############################################
# SG Rules
# - app SG allows port 80 (HTTP) from internal network
# - db SG allows port 5432 (Postgres) from internal network
#
# NOTE: You can change CIDR based on your VPC CIDR range.
############################################
security_groups_rule = {
  app = {
    name = "app"

    ingress_rules = [
      {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        description     = "HTTP Access"
        cidr_blocks     = ["10.0.0.0/8"]
        source_sg_names = []
      }
    ]

    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        description = "Allow all outbound"
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
        description     = "Postgres Access"
        cidr_blocks     = ["10.0.0.0/8"]
        source_sg_names = []
      }
    ]

    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        description = "Allow all outbound"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}

############################################
# EKS Cluster Security Group Rules
# This opens inbound to EKS cluster from node security groups
#
# Required:
# 443 for kubelet/cluster communication
############################################
eks_sg_rule = [
  {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
  }
]

############################################
# Node Group AMI Type (Mandatory)
# - AL2_x86_64 = Amazon Linux 2 (x86)
# - AL2_ARM_64 = ARM-based nodes
############################################
ami_type = "AL2_x86_64"

############################################
# Node Groups (Mandatory )
# You can define multiple node groups like:
# - app nodes
# - db nodes
# - monitoring nodes
#
# Each node group contains:
# - instance type
# - subnet ids
# - scaling settings
# - root EBS
# - taints/labels for scheduling workloads
############################################
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

    # Optional (Workload separation)
    taint = {
      key    = "app"
      value  = "true"
      effect = "NO_SCHEDULE"
    }

    # Node SG attachment
    sg_names = ["app"]

    # Optional labels for selectors
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

    # Optional (Workload separation)
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
