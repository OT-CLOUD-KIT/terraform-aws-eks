
#################### Security Groups ########################

create_sg = true
sg_names  = ["application-node", "database-node"]


private_subnet_ids = [
  "subnet-0759f0a3ac70e88c7", # us-east-1a
  "subnet-0d5d2a5274faf7485"  # us-east-1b
]

# Optional: Additional config if you're managing node groups too
application_subnet_ids = [
  "subnet-0d5d2a5274faf7485"  # Can also add more if needed
]

database_subnet_ids = [
  "subnet-0aeadc2711b9a9d6e"  # Can be reused or separate from above
]

vpc_id = "vpc-03ddd7fd3163cc23a"

########### application Security Groups ##########
security_groups_rule = {
  application-node = {
    name = "application-node"
    ingress_rules = [
      { from_port = 0, to_port = 0, protocol = "-1", description = "Allow all inbount", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 443, to_port = 443, protocol = "tcp", description = "Allow HTTPs traffic", source_sg_names = ["eks-cluster"] },
      { from_port = 10250, to_port = 10250, protocol = "tcp", description = "Allow kubelet communication from EKS control plane", source_sg_names = ["eks-cluster"] }
    ]
    egress_rules = [
      { from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound", cidr_blocks = ["0.0.0.0/0"] }
    ]
  }

  ######### databse Security Groups ##########
  database-node = {
    name = "database-node"
    ingress_rules = [
      { from_port = 0, to_port = 0, protocol = "-1", description = "Allow all inbound", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 443, to_port = 443, protocol = "tcp", description = "Allow HTTPs traffic", source_sg_names = ["eks-cluster"] },
      { from_port = 10250, to_port = 10250, protocol = "tcp", description = "Allow kubelet communication from EKS control plane", source_sg_names = ["eks-cluster"] }
    ]
    egress_rules = [
      { from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound", cidr_blocks = ["0.0.0.0/0"] }
    ]
  }
}

######## Cluster Security Groups ##########

eks_sg_rule = [
  {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
  },
  {
    from_port = 10250
    to_port   = 10250
    protocol  = "tcp"
  },
  {
    from_port = 1024
    to_port   = 65535
    protocol  = "-1"
  }
]

################## EKS Cluster ##############################
eks_cluster_version = "1.32"

eks_cluster_role_name   = "eks-cluster-roles"
eks_node_role_name      = "eks-node-roles"
endpoint_private_access = false
endpoint_public_access  = true


ami_type = "AL2023_x86_64_STANDARD"
key_pair = "KEY"

app_capacity_type         = "ON_DEMAND"
app_instance_type         = "t3.medium"
associate_public_ip_app   = false
delete_on_termination_app = true
app_encrypted             = true
ebs_app_volume_size       = "25"
ebs_app_volume_type       = "gp2"
app_taint_key             = "dedicated"
app_taint_value           = "application"
app_taint_effect          = "NO_SCHEDULE"

node_group_app_desired_size = 1
node_group_app_max_size     = 2
node_group_app_min_size     = 1


db_capacity_type         = "ON_DEMAND"
db_instance_type         = "t3.medium"
associate_public_ip_db   = false
delete_on_termination_db = true
db_encrypted             = true
ebs_db_volume_size       = "25"
ebs_db_volume_type       = "gp2"
db_taint_key             = "dedicated"
db_taint_value           = "database"
db_taint_effect          = "NO_SCHEDULE"

node_group_db_desired_size = 1
node_group_db_max_size     = 2
node_group_db_min_size     = 1


eks_cluster_role_policy_arns = {
  eks_cluster_node = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

eks_node_role_policy_arns = {
  eks_worker_node = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  eks_cni         = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ec2_readonly    = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

random_alphanumeric_len = 4

bu       = "ot"
app      = "bp"
env      = "d"
resource = "EKs"
tenant   = ""

special = false
upper   = false
number  = true

gen_no_of_names = 1

team    = "infra"
program = "ot"

