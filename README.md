# Terraform AWS EKS Cluster

A Terraform module to deploy a **highly configurable Amazon EKS Cluster** in AWS, complete with custom **application and database node groups**, **IAM roles**, **security groups**, and **launch templates**.

---

## Architecture

<img width="812" height="759" alt="image" src="https://github.com/user-attachments/assets/a4be2e97-022c-4c6a-a5d3-facdb068cbbe" />


> **Note:** This architecture supports private/public subnet configurations, custom launch templates for App/DB node groups, and secure security group rules.

---


## Providers

| Name                                              | Version  |
|---------------------------------------------------|----------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.82.2   |
| <a name="terraform_module"></a> [Terraform](Terraform\module) | >= 1.12.1|


---

## Usage

```hcl
## Usage Example


```hcl

module "EKS" {
  source = "../"
  eks_cluster_version          = "1.32"
  eks_cluster_role_name        = "eks-cluster-roles"
  eks_node_role_name           = "eks-node-roles"
  endpoint_private_access      = false
  endpoint_public_access       = true

  eks_cluster_role_policy_arns = {
    eks_cluster_node = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  }

  eks_node_role_policy_arns = {
    eks_worker_node = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    eks_cni         = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    ec2_readonly    = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }

  create_sg = true
  sg_names  = ["application-node", "database-node"]

  vpc_id = "vpc-03ddd7fd3163cc23a"

  private_subnet_ids = [
    "subnet-0759f0a3ac70e88c7",
    "subnet-0d5d2a5274faf7485"
  ]

  application_subnet_ids = [
    "subnet-0d5d2a5274faf7485"
  ]

  database_subnet_ids = [
    "subnet-0aeadc2711b9a9d6e"
  ]

  security_groups_rule = {
    application-node = {
      name = "application-node"
      ingress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          description = "Allow all inbound"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port         = 443
          to_port           = 443
          protocol          = "tcp"
          description       = "Allow HTTPs traffic"
          source_sg_names   = ["eks-cluster"]
        },
        {
          from_port         = 10250
          to_port           = 10250
          protocol          = "tcp"
          description       = "Allow kubelet communication"
          source_sg_names   = ["eks-cluster"]
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

    database-node = {
      name = "database-node"
      ingress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          description = "Allow all inbound"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port         = 443
          to_port           = 443
          protocol          = "tcp"
          description       = "Allow HTTPs traffic"
          source_sg_names   = ["eks-cluster"]
        },
        {
          from_port         = 10250
          to_port           = 10250
          protocol          = "tcp"
          description       = "Allow kubelet communication"
          source_sg_names   = ["eks-cluster"]
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

 
  ami_type = "AL2023_x86_64_STANDARD"
  key_pair = "KEY"

  ######################################
  # Application Node Group             #
  ######################################
  app_capacity_type           = "ON_DEMAND"
  app_instance_type           = "t3.medium"
  associate_public_ip_app     = false
  delete_on_termination_app   = true
  app_encrypted               = true
  ebs_app_volume_size         = "25"
  ebs_app_volume_type         = "gp2"
  node_group_app_desired_size = 1
  node_group_app_max_size     = 2
  node_group_app_min_size     = 1
  app_taint_key               = "dedicated"
  app_taint_value             = "application"
  app_taint_effect            = "NO_SCHEDULE"

  ######################################
  # Database Node Group                #
  ######################################
  db_capacity_type           = "ON_DEMAND"
  db_instance_type           = "t3.medium"
  associate_public_ip_db     = false
  delete_on_termination_db   = true
  db_encrypted               = true
  ebs_db_volume_size         = "25"
  ebs_db_volume_type         = "gp2"
  node_group_db_desired_size = 1
  node_group_db_max_size     = 2
  node_group_db_min_size     = 1
  db_taint_key               = "dedicated"
  db_taint_value             = "database"
  db_taint_effect            = "NO_SCHEDULE"
}
```
> **Note** This is a fully working example to deploy an EKS cluster using the `Eks` along with application and database node groups, custom security groups, and IAM roles.

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_iam_role.eks_cluster_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role.eks_node_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eks_node_role_attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.sg_to_eks_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_launch_template.eks_app_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_eks_node_group.app_node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_launch_template.eks_db_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_eks_node_group.db_node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |

___


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_sg"></a> [create_sg](#input_create_sg) | Whether to create security groups | `bool` | `true` | yes |
| <a name="input_sg_names"></a> [sg_names](#input_sg_names) | Names of the security groups to create | `list(string)` | `["application-node", "database-node"]` | yes |
| <a name="input_private_subnet_ids"></a> [private_subnet_ids](#input_private_subnet_ids) | List of private subnet IDs for the EKS cluster | `list(string)` | `[...]` | yes |
| <a name="input_application_subnet_ids"></a> [application_subnet_ids](#input_application_subnet_ids) | Subnets for the application node group | `list(string)` | `[...]` | yes |
| <a name="input_database_subnet_ids"></a> [database_subnet_ids](#input_database_subnet_ids) | Subnets for the database node group | `list(string)` | `[...]` | yes |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id) | VPC ID for EKS and security groups | `string` | `"vpc-03ddd7fd3163cc23a"` | yes |
| <a name="input_security_groups_rule"></a> [security_groups_rule](#input_security_groups_rule) | Ingress and egress rules for application and database SGs | `map(any)` | `{...}` | yes |
| <a name="input_eks_sg_rule"></a> [eks_sg_rule](#input_eks_sg_rule) | Rules to allow traffic to EKS cluster from node groups | `list(map(string))` | `[...]` | yes |
| <a name="input_eks_cluster_version"></a> [eks_cluster_version](#input_eks_cluster_version) | Version of EKS cluster | `string` | `"1.32"` | yes |
| <a name="input_eks_cluster_role_name"></a> [eks_cluster_role_name](#input_eks_cluster_role_name) | Name of IAM role for EKS cluster | `string` | `"eks-cluster-roles"` | yes |
| <a name="input_eks_node_role_name"></a> [eks_node_role_name](#input_eks_node_role_name) | Name of IAM role for EKS nodes | `string` | `"eks-node-roles"` | yes |
| <a name="input_endpoint_private_access"></a> [endpoint_private_access](#input_endpoint_private_access) | Enable private access to EKS endpoint | `bool` | `false` | yes |
| <a name="input_endpoint_public_access"></a> [endpoint_public_access](#input_endpoint_public_access) | Enable public access to EKS endpoint | `bool` | `true` | yes |
| <a name="input_ami_type"></a> [ami_type](#input_ami_type) | AMI type for node groups | `string` | `"AL2023_x86_64_STANDARD"` | yes |
| <a name="input_key_pair"></a> [key_pair](#input_key_pair) | Key pair name for SSH access | `string` | `"KEY"` | yes |
| <a name="input_app_capacity_type"></a> [app_capacity_type](#input_app_capacity_type) | Capacity type for app node group | `string` | `"ON_DEMAND"` | yes |
| <a name="input_app_instance_type"></a> [app_instance_type](#input_app_instance_type) | Instance type for app node group | `string` | `"t3.medium"` | yes |
| <a name="input_associate_public_ip_app"></a> [associate_public_ip_app](#input_associate_public_ip_app) | Assign public IP to app nodes | `bool` | `false` | yes |
| <a name="input_delete_on_termination_app"></a> [delete_on_termination_app](#input_delete_on_termination_app) | Whether EBS volume is deleted on app node termination | `bool` | `true` | yes |
| <a name="input_app_encrypted"></a> [app_encrypted](#input_app_encrypted) | Whether to encrypt app EBS volume | `bool` | `true` | yes |
| <a name="input_ebs_app_volume_size"></a> [ebs_app_volume_size](#input_ebs_app_volume_size) | Size of app EBS volume | `string` | `"25"` | yes |
| <a name="input_ebs_app_volume_type"></a> [ebs_app_volume_type](#input_ebs_app_volume_type) | Type of app EBS volume | `string` | `"gp2"` | yes |
| <a name="input_app_taint_key"></a> [app_taint_key](#input_app_taint_key) | Taint key for app node group | `string` | `"dedicated"` | yes |
| <a name="input_app_taint_value"></a> [app_taint_value](#input_app_taint_value) | Taint value for app node group | `string` | `"application"` | yes |
| <a name="input_app_taint_effect"></a> [app_taint_effect](#input_app_taint_effect) | Taint effect for app node group | `string` | `"NO_SCHEDULE"` | yes |
| <a name="input_node_group_app_desired_size"></a> [node_group_app_desired_size](#input_node_group_app_desired_size) | Desired size of app node group | `number` | `1` | yes |
| <a name="input_node_group_app_max_size"></a> [node_group_app_max_size](#input_node_group_app_max_size) | Max size of app node group | `number` | `2` | yes |
| <a name="input_node_group_app_min_size"></a> [node_group_app_min_size](#input_node_group_app_min_size) | Min size of app node group | `number` | `1` | yes |
| <a name="input_db_capacity_type"></a> [db_capacity_type](#input_db_capacity_type) | Capacity type for db node group | `string` | `"ON_DEMAND"` | yes |
| <a name="input_db_instance_type"></a> [db_instance_type](#input_db_instance_type) | Instance type for db node group | `string` | `"t3.medium"` | yes |
| <a name="input_associate_public_ip_db"></a> [associate_public_ip_db](#input_associate_public_ip_db) | Assign public IP to db nodes | `bool` | `false` | yes |
| <a name="input_delete_on_termination_db"></a> [delete_on_termination_db](#input_delete_on_termination_db) | Whether EBS volume is deleted on db node termination | `bool` | `true` | yes |
| <a name="input_db_encrypted"></a> [db_encrypted](#input_db_encrypted) | Whether to encrypt db EBS volume | `bool` | `true` | yes |
| <a name="input_ebs_db_volume_size"></a> [ebs_db_volume_size](#input_ebs_db_volume_size) | Size of db EBS volume | `string` | `"25"` | yes |
| <a name="input_ebs_db_volume_type"></a> [ebs_db_volume_type](#input_ebs_db_volume_type) | Type of db EBS volume | `string` | `"gp2"` | yes |
| <a name="input_db_taint_key"></a> [db_taint_key](#input_db_taint_key) | Taint key for db node group | `string` | `"dedicated"` | yes |
| <a name="input_db_taint_value"></a> [db_taint_value](#input_db_taint_value) | Taint value for db node group | `string` | `"database"` | yes |
| <a name="input_db_taint_effect"></a> [db_taint_effect](#input_db_taint_effect) | Taint effect for db node group | `string` | `"NO_SCHEDULE"` | yes |
| <a name="input_node_group_db_desired_size"></a> [node_group_db_desired_size](#input_node_group_db_desired_size) | Desired size of db node group | `number` | `1` | yes |
| <a name="input_node_group_db_max_size"></a> [node_group_db_max_size](#input_node_group_db_max_size) | Max size of db node group | `number` | `2` | yes |
| <a name="input_node_group_db_min_size"></a> [node_group_db_min_size](#input_node_group_db_min_size) | Min size of db node group | `number` | `1` | yes |
| <a name="input_eks_cluster_role_policy_arns"></a> [eks_cluster_role_policy_arns](#input_eks_cluster_role_policy_arns) | Map of policy ARNs for EKS cluster role | `map(string)` | `{...}` | yes |
| <a name="input_eks_node_role_policy_arns"></a> [eks_node_role_policy_arns](#input_eks_node_role_policy_arns) | Map of policy ARNs for EKS node role | `map(string)` | `{...}` | yes |
| <a name="input_random_alphanumeric_len"></a> [random_alphanumeric_len](#input_random_alphanumeric_len) | Length for generated random string | `number` | `4` | yes |
| <a name="input_bu"></a> [bu](#input_bu) | Business unit name | `string` | `"ot"` | yes |
| <a name="input_app"></a> [app](#input_app) | Application name | `string` | `"bp"` | yes |
| <a name="input_env"></a> [env](#input_env) | Environment name | `string` | `"d"` | yes |
| <a name="input_resource"></a> [resource](#input_resource) | Resource type | `string` | `"EKs"` | yes |
| <a name="input_tenant"></a> [tenant](#input_tenant) | Tenant (if multi-tenant) | `string` | `""` | no |
| <a name="input_special"></a> [special](#input_special) | Whether to include special chars in generated name | `bool` | `false` | no |
| <a name="input_upper"></a> [upper](#input_upper) | Whether to include uppercase chars in generated name | `bool` | `false` | no |
| <a name="input_number"></a> [number](#input_number) | Whether to include numbers in generated name | `bool` | `true` | no |
| <a name="input_gen_no_of_names"></a> [gen_no_of_names](#input_gen_no_of_names) | Number of names to generate | `number` | `1` | no |
| <a name="input_team"></a> [team](#input_team) | Team name | `string` | `"infra"` | yes |
| <a name="input_program"></a> [program](#input_program) | Program name | `string` | `"ot"` | yes |


___

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_cluster_name"></a> [eks_cluster_name](#output_eks_cluster_name) | The name of the EKS cluster |
| <a name="output_eks_cluster_arn"></a> [eks_cluster_arn](#output_eks_cluster_arn) | The ARN of the EKS cluster |
| <a name="output_eks_cluster_endpoint"></a> [eks_cluster_endpoint](#output_eks_cluster_endpoint) | The endpoint of the EKS cluster |
| <a name="output_eks_cluster_sg"></a> [eks_cluster_sg](#output_eks_cluster_sg) | The security group ID of the EKS cluster |
| <a name="output_eks_node_group_app"></a> [eks_node_group_app](#output_eks_node_group_app) | The name of the EKS node group for the application |
| <a name="output_eks_node_group_db"></a> [eks_node_group_db](#output_eks_node_group_db) | The name of the EKS node group for the database |
| <a name="output_eks_node_group_role_arn"></a> [eks_node_group_role_arn](#output_eks_node_group_role_arn) | The ARN of the node group role |


___

## Contributors

- [Piyush Upadhyay](https://github.com/piiiyuushh)
- [Nikita Joshi](https://github.com/jnikita19)

