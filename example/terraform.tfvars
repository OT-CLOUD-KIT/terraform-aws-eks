roles = [
  {
    name          = "ekscluster_role"
    assume_policy = "./environments/dev/eks_cluster_assume_policy.json"
  },
  {
    name          = "eksnodegroup_role"
    assume_policy = "./environments/dev/eks_node_group_assume_policy.json"
  }
]
cluster_policy = [
  "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
  "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
]
node_policy = [
  "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

]
aws_region      = "ap-south-1"
subnet_ids      = ["subnet-08ac4215773c4c7f1", "subnet-05ea90a00562ead8e"]
cluster_name    = "OT-microservices"
env             = "dev"
cluster_version = "1.30"
vpc_id          = "vpc-087439c673e8a354e"
key_pair        = "ec2-keypair"
node_image_id   = "ami-003c0d8931dc3f095"

node_groups = [
  {
    name          = "worker-1-nodes"
    instance_type = "t3a.medium"
    volume_size   = 20
    desired_size  = 1
    max_size      = 2
    min_size      = 1
    user_data     = "./environments/dev/node_group_user_data.sh"
    labels = {
      "worker-1" = "enabled"
    }
    taint = [
      {
        key    = "worker-1"
        value  = "enabled"
        effect = "NO_SCHEDULE"
      }
    ]
    capacity_type      = "SPOT"
    kubelet_extra_args = "--max-pods=20 --node-labels=worker-1-nodes=enabled"
    taint              = []
    tag_name           = "dev"
    node_instance_tags = {
      "Environment" = "QA"
      "Team"        = "DevOps"
      "Role"        = "eksnodegroup_roler"
    }

    node_volume_tags = {
      "Environment" = "QA"
      "VolumeType"  = "WorkerNodeEBS"
    }
  },
  {
    name          = "worker-2-nodes"
    instance_type = "t3a.medium"
    volume_size   = 20
    desired_size  = 1
    max_size      = 2
    min_size      = 1
    user_data     = "./environments/dev/node_group_user_data.sh"
    labels = {
      "worker-2" = "enabled"
    }
    taint = [
      {
        key    = "worker-2"
        value  = "enabled"
        effect = "NO_SCHEDULE"
      }
    ]
    capacity_type      = "ON_DEMAND"
    kubelet_extra_args = "--max-pods=20 --node-labels=worker-2-nodes=enabled"
    taint              = []
    tag_name           = "dev"
    node_instance_tags = {
      "Environment" = "QA"
      "Team"        = "DevOps"
      "Role"        = "eksnodegroup_role"
    }

    node_volume_tags = {
      "Environment" = "QA"
      "VolumeType"  = "WorkerNodeEBS"
    }
  }
]
eks_addons = [
  { name = "vpc-cni", version = "v1.19.2-eksbuild.1" }, # Example version for VPC CNI compatible with 1.31          # Example version for CoreDNS compatible with 1.31
  { name = "kube-proxy", version = "v1.30.6-eksbuild.3" },
  { name = "coredns", version = "v1.11.1-eksbuild.8" }, # Example version for kube-proxy compatible with 1.31
  { name = "aws-ebs-csi-driver", version = "v1.43.0-eksbuild.1" }
]

eks_ingress = [
  {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

eks_egress = [
  {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
]

# New variables
enable_public_endpoint = true # Disable public endpoint
authentication_mode    = true  # Enable API/ConfigMap access
eks_cluster_sg_rules = {
  rule1 = {
    from_port                = 443
    to_port                  = 443
    source_security_group_id = "sg-08513b073867293b6"
  }
}
