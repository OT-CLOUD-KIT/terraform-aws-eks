variable "sub_az" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
  default     = "non-prod-petpark-eks-cluster-test"
}

variable "ssh_key" {
  description = "ssh keys"
  type        = string
  default     = "non-prodeks"

}
variable "kubeconfig_file_name" {
  description = "kubeconfig file name"
  type        = string
  default     = "config"  
}

variable "node_group_name" {
  description = "node group name"
  type        = string
  default     = "non-prod-eks-node-group-test"
}
