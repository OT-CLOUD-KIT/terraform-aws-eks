variable "cluster_name" {
  description = "EKS cluster name"
  default     = "terraform-eks-demo"
  type        = string
}

variable "eks_node_group_name" {
  description = "Node group name for EKS"
  default     = "eks-node-group"
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

variable "subnets" {
  description = "A list of subnets for worker nodes"
  type        = list(string)
}

variable "eks_cluster_version" {
  description = "Kubernetes cluster version in EKS"
  type        = string
}

variable "disk_size" {
  description = "Disk size of workers"
  type        = number
  default     = 20
}

variable "scale_min_size" {
  description = "Minimum count of workers"
  type        = number
  default     = 2
}

variable "scale_max_size" {
  description = "Maximum count of workers"
  type        = number
  default     = 5
}

variable "scale_desired_size" {
  description = "Desired count of workers"
  type        = number
  default     = 3
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "config_output_path" {
  description = "kubeconfig output path"
  type        = string
}

variable "kubeconfig_name" {
  description = "Name of kubeconfig file"
  type        = string
}

variable "endpoint_private" {
  description = "endpoint private"
  type = bool
}
variable "endpoint_public" {
  description = "endpoint public"
  type = bool
}

variable "slackUrl" {
  description = "Slack Web hook URL"
  type = string
}

variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "create_spot_node_group" {
  description = "Create node group or not"
  type        = bool
}

variable "create_node_group" {
  description = "Create node group or not"
  type        = bool
}

variable "allow_eks_cidr" {
  description = "allow eks cidr"
  type = list(string)
  default = ["0.0.0.0/32"]
}

variable "node_groups" {
  description = "Paramters which are required for creating node group"
  type = map(object({
    subnets            = list(string)
    instance_type      = list(string)
    disk_size          = number
    desired_capacity   = number
    max_capacity       = number
    min_capacity       = number
    ssh_key            = string
    security_group_ids = list(string)
    tags               = map(string)
    labels             = map(string)
  }))
}

variable "spot_node_group" {
  description = "Paramters which are required for creating spot node group"
  type = map(object({
    subnets             = list(string)
    instance_type       = string
    ami_id              = string
    disk_size           = number
    desired_capacity    = number
    max_capacity        = number
    min_capacity        = number
    ssh_key             = string
    spot_price          = string
    security_group_ids  = list(string)
    tags                = map(string)
    spot_instance_pools = string
    spot_max_price      = string
  }))
}
