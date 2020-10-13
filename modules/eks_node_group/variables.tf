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

variable "cluster_name" {
  description = "Name of parent cluster"
  type        = string
}

variable "node_role_arn" {
  description = "IAM Role ARN for node groups"
  type        = string
}

variable "create_node_group" {
  description = "Create node group or not"
  type        = bool
}
