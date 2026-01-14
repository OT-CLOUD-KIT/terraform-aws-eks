###################### Project Info ########################

variable "bu" { type = string }
variable "program" { type = string }
variable "app" { type = string }
variable "env" { type = string }
variable "team" { type = string }
variable "region" { type = string }
variable "mission" { type = string }

###################### EKS Cluster #########################

variable "eks_cluster_version" { type = string }

variable "endpoint_private_access" {
  type    = bool
  default = true
}

variable "endpoint_public_access" {
  type    = bool
  default = false
}

variable "private_subnet_ids" {
  type = list(string)
}

###################### IAM #################################

variable "eks_cluster_role_name" {
  type = string
}

variable "eks_cluster_role_policy_arns" {
  type = map(string)
}

variable "eks_node_role_name" {
  type = string
}

variable "eks_node_role_policy_arns" {
  type = map(string)
}

###################### SG ##################################

variable "create_sg" {
  type    = bool
  default = true
}

variable "vpc_id" {
  type = string
}

variable "sg_names" {
  type    = list(string)
  default = []
}

variable "security_groups_rule" {
  type = map(object({
    name = string
    ingress_rules = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      description     = string
      cidr_blocks     = optional(list(string), [])
      source_sg_names = optional(list(string), [])
    }))
    egress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      description = string
      cidr_blocks = list(string)
    }))
  }))
  default = {}
}

variable "eks_sg_rule" {
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
  }))
  default = []
}

###################### Node Groups #########################

variable "ami_type" {
  type = string
}

variable "key_pair" {
  type    = string
  default = ""
}

variable "node_groups" {
  type = map(object({
    subnet_ids          = list(string)
    capacity_type       = string
    instance_type       = string
    associate_public_ip = bool

    scaling_config = object({
      desired_size = number
      min_size     = number
      max_size     = number
    })

    ebs = object({
      volume_size           = number
      volume_type           = string
      delete_on_termination = bool
      encrypted             = bool
    })

    taint = object({
      key    = string
      value  = string
      effect = string
    })

    sg_names = list(string)

    labels = map(string)
  }))
}
