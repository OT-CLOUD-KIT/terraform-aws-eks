module "non_prod_eks_cluster" {
  source              = "../"
  cluster_name        = "non-prod-eks"
  eks_cluster_version = "1.15"
  vpc_subnet          = [
                          "subnet-073d",
                          "subnet-0a", 	
                          "subnet-08f",
                          "subnet-09"
                          ]
  node_group_name     = "non-prod-eks-node"
  instance_type       = ["m5a.xlarge"]
  eks_cluster_tag     = { "test-esk" = "test" }
  disk_size           = 40
  scale_desired_size  = 3
  scale_max_size      = 5
  scale_min_size      = 2
}
