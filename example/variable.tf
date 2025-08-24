

variable "env" {
  type    = string
  default = "d"
}

variable "bu" {
  type    = string
  default = "ot"
}

variable "app" {
  type    = string
  default = "bp"
}

variable "resource" {
  type    = string
  default = "instance"
}

variable "tenant" {
  type    = string
  default = ""
}

variable "enabled_features" {
  type    = list(string)
  default = []
}

variable "random_alphanumeric_len" {
  type    = number
  default = 4
}

variable "special" {
  type    = bool
  default = false
}

variable "upper" {
  type    = bool
  default = false
}

variable "number" {
  type    = bool
  default = true
}

variable "gen_no_of_names" {
  type    = number
  default = 1
}

####################################
# Tags & Metadata
####################################
variable "team" {
  type    = string
  default = "infra"
}

variable "program" {
  type    = string
  default = "ot"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "provisioner" {
  type    = string
  default = "terraform"
}

variable "tags" {
  type    = map(string)
  default = {}
}


###################### EKS Cluster  ####################

variable "eks_cluster_version" {
  type        = string
  description = "EKS Kubernetes version"
  default     = ""
}

variable "endpoint_private_access" {
  type = bool
}

variable "endpoint_public_access" {
  type = bool

}


variable "private_subnet_ids" {
  type    = list(string)
  default = ["subnet-091894e1c2db297b5"]
}

################# Policy

variable "eks_cluster_role_name" {
  type        = string
  description = "IAM Role name for EKS cluster"
  default     = ""
}

variable "eks_cluster_role_policy_arns" {
  type = map(string)
  default = {
    eks_cluster_node = ""
  }
}

variable "eks_node_role_policy_arns" {
  type = map(string)
  default = {
    eks_worker_node = ""
    eks_cni         = ""
    ec2_readonly    = ""
  }
}

variable "eks_node_role_name" {
  type        = string
  description = "IAM Role name for EKS cluster"
  default     = ""
}



#################### Security Groups ########################

#node sg

variable "sg_names" {
  description = "List of security group keys/names"
  type        = list(string)
  default     = []
}

variable "security_groups_rule" {
  description = "Map of security group rules"
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
}

variable "sg_egress_type" {
  default = "egress"
  type    = string

}

variable "sg_ingress_type" {
  default = "ingress"
  type    = string

}

variable "create_sg" {
  description = "Set to true to create security groups"
  type        = bool
}



variable "eks_security_group_ids" {
  description = "List of security group IDs for the EKS cluster."
  type        = list(string)
  default     = []
}

### cluster sg

variable "eks_sg_rule" {
  description = "Rules for EKS cluster security group ingress from other SGs"
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
  }))
}

###################### Node Group  ####################

variable "ami_type" {
  type        = string
  default     = ""
  description = "value of ami_type"

}

variable "key_pair" {
  description = "Optional key pair name for EC2 instances"
  type        = string
  default     = ""
}


####### App Node Group  ######

variable "application_subnet_ids" {
  type    = list(string)
  default = ["subnet-045f69efd16f93d00"]

}

variable "app_capacity_type" {
  type        = string
  default     = ""
  description = "value of capacity_type for app"
}

####
variable "associate_public_ip_app" {
  type        = bool
  description = "value of associate_public_ip_address for app"
}

variable "delete_on_termination_app" {
  type        = bool
  description = "value of delete_on_termination for app"

}

variable "app_encrypted" {
  type        = bool
  description = "value of encrypted for app"
}

####

variable "app_instance_type" {
  type        = string
  default     = ""
  description = "EC2 instance type for app worker nodes"
}

variable "ebs_app_volume_size" {
  type        = string
  default     = ""
  description = "EBS volume size for app worker nodes"
}

variable "ebs_app_volume_type" {
  type        = string
  default     = ""
  description = "EBS volume type for app worker nodes"

}

variable "node_group_app_desired_size" {
  type = number
}

variable "node_group_app_max_size" {
  type = number
}

variable "node_group_app_min_size" {
  type = number

}


variable "app_taint_key" {
  type        = string
  default     = ""
  description = "value of taint_key for app"
}
variable "app_taint_value" {
  type        = string
  default     = ""
  description = "value of taint_value for app"
}

variable "app_taint_effect" {
  type        = string
  default     = ""
  description = "value of taint_effect for app"

}



####### DB Node Group  ######

variable "db_taint_key" {
  type        = string
  default     = ""
  description = "value of taint_key for db"
}
variable "db_taint_value" {
  type        = string
  default     = ""
  description = "value of taint_value for db"
}

variable "db_taint_effect" {
  type        = string
  default     = ""
  description = "value of taint_effect for db"

}

variable "db_capacity_type" {
  type        = string
  default     = ""
  description = "value of capacity_type for db"
}

###
variable "associate_public_ip_db" {
  type        = bool
  description = "value of associate_public_ip_address for db"
}

variable "delete_on_termination_db" {
  type        = bool
  description = "value of delete_on_termination for db"

}

variable "db_encrypted" {
  type        = bool
  description = "value of encrypted for db"
}

###
variable "db_instance_type" {
  type        = string
  default     = ""
  description = "EC2 instance type for db worker nodes"
}

variable "ebs_db_volume_size" {
  type        = string
  default     = ""
  description = "EBS volume size for app worker nodes"
}

variable "ebs_db_volume_type" {
  type        = string
  default     = ""
  description = "EBS volume type for db worker nodes"

}

variable "node_group_db_desired_size" {
  type = number
}

variable "node_group_db_max_size" {
  type = number
}

variable "node_group_db_min_size" {
  type = number
}

variable "database_subnet_ids" {
  type    = list(string)

  
  default = ["subnet-01fb2096c79aead83"]

}
variable "vpc_id" {
  type    = string
  default = "vpc-0584bf21acbf558a1"

}



