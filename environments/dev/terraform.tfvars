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

cluster-policy = [
  "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
  "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
]
node-policy = [
  "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
]

cluster_subnets = ["sd2-dr-pvt-subnet-1", "sd2-dr-pvt-subnet-2", "sd2-dr-pvt-subnet-3"]
cluster-name    = "sd2-dr-cluster"
env             = "dev"
vpc_id          = "vpc-0fbb5d1097a38da38"
key_pair        = "opstree"

node_groups = [
  {
    name               = "sd2-dr-worker-1"
    instance_type      = "t3a.medium"
    volume_size        = 20
    desired_size       = 2
    max_size           = 20
    min_size           = 1
    user_data          = "./environments/dev/node_group_user_data.sh"
    labels             = { "sd2-dr-worker-1" = "enabled" }
    kubelet_extra_args = "--max-pods=20 --node-labels=sd2-dr-worker-1=enabled"
    taint              = []
    tag-name           = null
  },
  {
    name               = "sd2-dr-worker-2"
    instance_type      = "t3a.medium"
    volume_size        = 20
    desired_size       = 2
    max_size           = 20
    min_size           = 1
    user_data          = "./environments/dev/node_group_user_data.sh"
    labels             = { "sd2-dr-worker-2" = "enabled" }
    kubelet_extra_args = "--max-pods=20 --node-labels=sd2-dr-worker-2=enabled"
    taint              = []
    tag-name           = null
  }
]

private_subnets = ["sd2-dr-pvt-subnet-1", "sd2-dr-pvt-subnet-2", "sd2-dr-pvt-subnet-3"]

eks_addons = [
  { name = "vpc-cni", version = "v1.18.6-eksbuild.1" },
  { name = "kube-proxy", version = "v1.31.1-eksbuild.2" },
  { name = "coredns", version = "v1.11.3-eksbuild.1" },
  { name = "aws-ebs-csi-driver", version = "v1.36.0-eksbuild.1" }
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
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
]

# New variables
enable_public_endpoint    = false
authentication_mode       = true
enable_cluster_autoscaler = true
capacity_type             = "ON_DEMAND"
