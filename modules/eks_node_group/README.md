#eks_node_group

```hcl
module "second_nodegroup" {
  source         = "../eks_node_group"
  eks_cluster_id = module.qa_eks_cluster.eks_cluster_id
  vpc_subnet = [
    "subnet-033ae470c557da34a",
    "subnet-07abb30e64c0f9ca0",
    "subnet-0f42b261befb468e2"
  ]
  node_group_name    = "eks-node-test"
  instance_type      = ["t2.large"]
  tags               = local.tags_map
  disk_size          = 40
  scale_desired_size = 3
  scale_max_size     = 5
  scale_min_size     = 3
  ssh_key            = "default"
  security_group_ids = ["sg-0f29d4e4332979101"]
  role_arn           = module.qa_eks_cluster.node_iam_role_arn
}
```