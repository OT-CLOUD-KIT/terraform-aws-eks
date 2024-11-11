variable "roles" {
  description = "List of IAM roles to create."
  type = list(object({
    name            = string                       
    assume_policy   = string                                     
  }))
}
variable "cluster-policy" {
    type = list(string)
}
variable "node-policy" {
    type = list(string)
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
    security_group = list(string)      
    desired_size = number                 
    max_size     = number                 
    min_size     = number                 
    labels       = map(string)  
    user_data = string          
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
variable "eks_addons" {
  description = "List of EKS addons to install"
  type = list(object({
    name    = string
    version = string
  }))
}
