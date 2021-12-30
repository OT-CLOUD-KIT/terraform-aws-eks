variable "cluster_name" {
  description = "EKS cluster name"
  default     = "terraform-eks-demo"
  type        = string
}

variable "cluster_autoscaler" {
  description = "For Cluster Cluster Autoscalling"
  default     = true
  type        = bool
}

variable "metrics_server" {
  description = "For Metrics Server"
  default     = true
  type        = bool
}

variable "k8s-spot-termination-handler" {
  description = "For Spot Instance termination handler"
  default     = true
  type        = bool
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

variable "create_node_group" {
  description = "Create node group or not"
  type        = bool
  default     = true
}

variable "allow_eks_cidr" {
  description = "allow eks cidr"
  type = list(string)
  default = ["0.0.0.0/32"]
}

variable "force_update_version" {
  type        = bool
  description = "Force version update if existing pods are unable to be drained due to a pod disruption budget issue."
  default     = false
}

variable "cluster_endpoint_whitelist" {
  type = bool
  description = "For Wihtelist the cluster endpoint"
  default = false
}

variable "cluster_endpoint_access_cidrs" {
  type = list(string)
  description = "For list of cidr to whitelist"
  default = []
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
    capacity_type      = string
  }))
}

variable "enabled_cluster_log_types" {
description = "List of the desired control plane logging to enable"
type = list(string)
default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "enable_oidc" {
  description = "Condition to provide OpenID Connect identity provider information for the cluster"
  type = bool
  default = true
}

variable "map_additional_iam_roles" {
  description = "Additional IAM roles to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "add_additional_iam_roles" {
  description = "Condition to map additinal iam roles in EKS config map"
  type = bool
  default = true
}