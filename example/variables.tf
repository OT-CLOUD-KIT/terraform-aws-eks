variable "roles" {
  description = "List of IAM roles to create."
  type = list(object({
    name          = string
    assume_policy = string
  }))
}
variable "env" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "cluster_version" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "node_image_id" {
  type = string
}

variable "cluster_policy" {
  type = list(string)
}
variable "node_policy" {
  type = list(string)
}
variable "cluster_name" {
  type = string
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
    capacity_type      = string
    kubelet_extra_args = string
    tag_name = string
    node_instance_tags = map(string)
    node_volume_tags = map(string)
    taint = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
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
variable "eks_cluster_sg_rules" {
  description = "List of EKS cluster security group rules"
  type = map(object({
    from_port                = number
    to_port                  = number
    source_security_group_id = string
  }))
}
variable "enable_public_endpoint" {
  description = "Enable or disable public endpoint access for the EKS cluster"
  type        = bool
  default     = true
}
variable "authentication_mode" {
  description = "Enable or disable ConfigMap for API access"
  type        = bool
  default     = true
}

##########Autoscaler-Variables############
variable "enable_cluster_autoscaler" {
  description = "Enable or disable the EKS Cluster Autoscaler"
  type        = bool
  default     = true
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}


variable "node_role" {
  type    = string
  default = "eksnodegroup_role"
}

