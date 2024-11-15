variable "cluster-role" {
    type = string
}
variable "cluster_subnets" {
    type = list(string)
}
variable "cluster-name"{
    type = string
}
variable "node_groups" {
  type = list(object({
    name           = string               
    instance_type  = string               
    volume_size    = number               
    security_group = string      
    desired_size = number                 
    max_size     = number                 
    min_size     = number                 
    labels       = map(string)          
    taint = list(object({                 
      key    = string
      value  = string
      effect = string
    }))   
  }))
}
variable "private_subnets" {
    type = list(string)
}
variable "node_role"{
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
