roles = [
  {
    name             = "ekscluster_role"
    assume_policy    = "./environments/dev/eks_cluster_assume_policy.json"
  },
  {
    name             = "eksnodegroup_role"
    assume_policy    = "./environments/dev/eks_node_group_assume_policy.json"
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

cluster_subnets = ["Public-1", "Public-2"]
cluster-name    = "OT-microservices"

node_groups = [
    # {
    # name           = "attedance-nodes"               
    # instance_type  = "t3.medium"               
    # volume_size    = "20"               
    # security_group = ["sg-0206380f8bf996e47"]      
    # desired_size = 2                
    # max_size     = 2                 
    # min_size     = 1     
    # user_data = "./environments/dev/node_group_user_data.sh"            
    # labels = {
    #     "attendance" = "enabled"
    #   }            
    # taint = [
    #     {
    #       key    = "attendance"
    #       value  = "enabled"
    #       effect = "NO_SCHEDULE"
    #     }
    #   ]
    # },
    {
    name           = "master-node"               
    instance_type  = "t3.medium"               
    volume_size    = "20"               
    security_group = "sg-0206380f8bf996e47"    
    desired_size = 2                
    max_size     = 2                 
    min_size     = 1     
    user_data = "./environments/dev/node_group_user_data.sh"            
    labels = {
        "attendance" = "enabled"
      }            
    taint = []
    }
]
private_subnets = ["Private-1", "Private-2"]
eks_addons = [
     { name = "vpc-cni", version = "v1.18.6-eksbuild.1" },           # Example version for VPC CNI compatible with 1.31          # Example version for CoreDNS compatible with 1.31
    { name = "kube-proxy", version = "v1.31.1-eksbuild.2" },
    {name = "coredns", version = "v1.11.3-eksbuild.1"},      # Example version for kube-proxy compatible with 1.31
    { name = "aws-ebs-csi-driver", version = "v1.36.0-eksbuild.1" } 
]

