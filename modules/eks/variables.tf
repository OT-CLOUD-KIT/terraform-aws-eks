variable "cluster-role" {
    type = string
}
variable "env" {
  type = string
}

variable "cluster_subnets" {
    type = list(string)
}

variable "cluster-name" {
    type = string
}
variable "vpc_id" {
  type = string
}
variable "node_groups" {
  type = list(object({
    name           = string               
    instance_type  = string               
    volume_size    = number                    
    desired_size   = number                 
    max_size       = number                 
    min_size       = number                 
    labels         = map(string)     
    kubelet_extra_args = string     
    taint = list(object({                 
      key    = string
      value  = string
      effect = string
    }))
    tag-name  = string
  }))
}

variable "private_subnets" {
    type = list(string)
}

variable "node_role" {
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
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
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
  default     = "ON_DEMAND"  # Default to ON_DEMAND
}
