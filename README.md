# EKS

[![Opstree Solutions][opstree_avatar]][opstree_homepage]<br/>[Opstree Solutions][opstree_homepage] 

  [opstree_homepage]: https://opstree.github.io/
  [opstree_avatar]: https://img.cloudposse.com/150x150/https://github.com/opstree.png

- This terraform module will create a EKS Cluster.
- This projecct is a part of opstree's ot-aws initiative for terraform modules.

## Usage

```sh
$   cat main.tf
/*-------------------------------------------------------*/
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
/*-------------------------------------------------------*/
```

```sh
$   cat output.tf
/*-------------------------------------------------------*/
output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority.0.data
}
/*-------------------------------------------------------*/
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cluster_name | Name of Your Cluster. | string | null | yes |
| vpc_subnet | A list of subnet IDs to launch resources in. | List | null | yes |
| eks_cluster_version | Define Kubernetes Version to install. | string | null | yes |
| eks_cluster_tag | eks Cluster Tag. | map(string) | null | yes |
| node_group_name | node group name to attach in EKS. | string | null | yes |
| instance_type | Define Instance type ie. "t2.medium". | lint(string) | null | yes |
| disk_size | Define Disk size of nodes. | number | null | yes |
| scale_min_size | Define minimum nodes scaling. | number | null | yes |
| scale_max_size | Define Max nodes scaling. | number | null | yes |
| scale_desired_size | Define Desire nodes. | number | null | yes |
| scale_desired_size | Define Desire nodes. | number | null | yes |


## Outputs

| Name | Description |
|------|-------------|
| launch_template_name | Name of the launch template |
| launch_template_default_version | Default of the launch template |
| launch_template_latest_version | Latest of the launch template |
| target_group_arn | ARN of the target group |
| route53_name | Name of the record created |

## Future proposed changes

- Add capability to setup without ALB & then health check would be EC2 instance
 
## Related Projects

Check out these related projects.

- [network_skeleton](https://gitlab.com/ot-aws/terrafrom_v0.12.21/network_skeleton) - Terraform module for providing a general purpose Networking solution
- [security_group](https://gitlab.com/ot-aws/terrafrom_v0.12.21/security_group) - Terraform module for creating dynamic Security groups
- [HA_ec2_ALB](https://gitlab.com/ot-aws/terrafrom_v0.12.21/ha_ec2_alb) - Terraform module will create a Highly available setup of an EC2 instance with quick disater recovery.
- [rds](https://gitlab.com/ot-aws/terrafrom_v0.12.21/rds) - Terraform module for creating Relation Datbase service.
- [HA_ec2](https://gitlab.com/ot-aws/terrafrom_v0.12.21/ha_ec2.git) - Terraform module for creating a Highly available setup of an EC2 instance with quick disater recovery.
- [rolling_deployment](https://gitlab.com/ot-aws/terrafrom_v0.12.21/rolling_deployment.git) - This terraform module will orchestrate rolling deployment.

### Contributors

[![Devesh Sharma][sudipt_avatar]][devesh_homepage]<br/>[Sudipt Sharma][devesh_homepage] 

  [devesh_homepage]: https://github.com/deveshs23
  [devesh_avatar]: https://img.cloudposse.com/150x150/https://github.com/deveshs23.png