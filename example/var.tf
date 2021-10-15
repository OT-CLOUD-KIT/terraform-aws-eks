variable "cluster_name" {
  description = "Cluster name"
  type        = string
  default     = "non-prod-eks-cluster"
}

variable "ssh_key" {
  description = "ssh keys"
  type        = string
  default     = "BuildPiper"

}
variable "kubeconfig_file_name" {
  description = "kubeconfig file name"
  type        = string
  default     = "config"
}

variable "node_group_name" {
  description = "node group name"
  type        = string
  default     = "non-prod-eks-node-group"
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
  default     = "vpc-079**********"
}

variable "private_subnet_id" {
  description = "private subnet id"
  type        = list(string)
  default     = ["subnet-**************", "subnet-************"]
}

variable "public_subnet_id" {
  description = "public subnet id"
  type        = list(string)
  default     = ["subnet-************", "subnet-************"]
}
