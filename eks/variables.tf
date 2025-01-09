variable "cluster-role" {
  type = string
}
variable "env" {
  type = string
}

variable "cluster_subnets" {
  type = list(string)
}

variable "cluster_name" {
  type = string
}
variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "node_groups" {
  type = list(object({
    name               = string
    instance_type      = string
    volume_size        = number
    desired_size       = number
    max_size           = number
    min_size           = number
    labels             = map(string)
    kubelet_extra_args = string
    taint = list(object({
      key    = string
      value  = string
      effect = string
    }))
    tag_name = string
  }))
}

# variable "private_subnets" {
#   type = list(string)
# }

variable "node_role" {
  type    = string
  default = "eksnodegroup_role"
}
variable "key_pair" {
  type = string
}

variable "eks_addons" {
  description = "List of EKS addons to install"
  type = list(object({
    name    = string
    version = string
  }))
}

variable "eks_ingress" {
  description = "A list of ingress rules for ecs service"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "eks_egress" {
  description = "A list of egress rules for ecs service"
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
  }))
}

# New variable to toggle public or private endpoint access
variable "enable_public_endpoint" {
  description = "Boolean to enable or disable the public endpoint for the EKS cluster"
  type        = bool
  default     = true
}

variable "authentication_mode" {
  description = "Enable or disable the aws-auth ConfigMap for API and node authentication"
  type        = bool
  default     = true
}

variable "capacity_type" {
  description = "The capacity type for EKS Node Group. Options are 'ON_DEMAND' or 'SPOT'."
  type        = string
  default     = "ON_DEMAND" # Default to ON_DEMAND
}


########################################################################################
# Enable or disable Cluster Autoscaler
variable "enable_cluster_autoscaler" {
  description = "Enable or disable the EKS Cluster Autoscaler"
  type        = bool
  default     = true
}

# AWS Region
variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

# # EKS Cluster Name
# variable "cluster_name" {
#   description = "The name of the EKS cluster"
#   type        = string
# }


output "node_group_role_arn" {
  value       = var.node_role
  description = "ARN of the IAM role associated with the EKS node group."
}
variable "eks_cluster_sg_rules" {
  description = "List of EKS cluster security group rules"
  type = map(object({
    from_port                = number
    to_port                  = number
    source_security_group_id = string
  }))
}