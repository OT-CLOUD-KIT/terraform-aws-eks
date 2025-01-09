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
  "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
]

cluster_subnets = ["rajat-dr-pvt-subnet-1", "rajat-dr-pvt-subnet-2", "rajat-dr-pvt-subnet-3"]
cluster_name    = "rajat-dr-cluster"
env             = "dev"
vpc_id          = "vpc-04e17b61dfc861411"
key_pair        = "opstree"

node_groups = [
  {
    name               = "rajat-dr-worker-1"
    instance_type      = "t3a.medium"
    volume_size        = 8
    desired_size       = 1
    max_size           = 8
    min_size           = 1
    user_data          = "./environments/dev/node_group_user_data.sh"
    labels             = { "rajat-dr-worker-1" = "enabled" }
    kubelet_extra_args = "--max-pods=20 --node-labels=rajat-dr-worker-1=enabled"
    taint              = []
    tag_name           = null
  },
  {
    name               = "rajat-dr-worker-2"
    instance_type      = "t3a.medium"
    volume_size        = 8
    desired_size       = 1
    max_size           = 8
    min_size           = 1
    user_data          = "./environments/dev/node_group_user_data.sh"
    labels             = { "rajat-dr-worker-2" = "enabled" }
    kubelet_extra_args = "--max-pods=20 --node-labels=rajat-dr-worker-2=enabled"
    taint              = []
    tag_name           = null
  }
]

subnet_ids = ["subnet-0bb31c6137c07c782", "subnet-0dc35556d7d0acebd"]

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
enable_cluster_autoscaler = false
capacity_type             = "ON_DEMAND"
aws_region = "us-east-1"
