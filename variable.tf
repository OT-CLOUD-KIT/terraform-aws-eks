
###################### EKS Cluster  ####################

variable "eks_cluster_version" {
  type        = string
  description = "EKS Kubernetes version"
  default     = ""
}

variable "endpoint_private_access" {
  type    = bool
  default = true

}

variable "endpoint_public_access" {
  type    = bool
  default = false

}


variable "private_subnet_ids" {
  type    = list(string)
  default = []
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
  default     = true
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
  description = "value of ami_type for db"

}

variable "key_pair" {
  description = "Optional key pair name for EC2 instances"
  type        = string
  default     = ""
}


####### App Node Group  ######

variable "application_subnet_ids" {
  type    = list(string)
  default = []

}

variable "app_capacity_type" {
  type        = string
  default     = ""
  description = "value of capacity_type for app"
}

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
  type    = number

}

variable "node_group_app_max_size" {
  type    = number

}

variable "node_group_app_min_size" {
  type    = number

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


variable "db_instance_type" {
  type        = string
  default     = ""
  description = "EC2 instance type for db worker nodes"
}

variable "ebs_db_volume_size" {
  type        = string
  default     = ""
  description = "EBS volume size for db worker nodes"
}

variable "ebs_db_volume_type" {
  type        = string
  default     = ""
  description = "EBS volume type for db worker nodes"

}

variable "node_group_db_desired_size" {
  type    = number
}

variable "node_group_db_max_size" {
  type    = number
}

variable "node_group_db_min_size" {
  type    = number
}

variable "database_subnet_ids" {
  type    = list(string)
  default = []

}
variable "vpc_id" {
  type    = string
  default = ""

}


####################### Project Info ########################

variable "bu" {
  description = "Business unit name (e.g., BP, GURUKU). Max 6 characters."
  type        = string
  default     = "BP"

  validation {
    condition     = length(var.bu) <= 10
    error_message = "The business unit name must be less than or equal to 10 characters."
  }
}

variable "program" {
  description = "Name of the program (e.g., OT, BP)."
  type        = string
  default     = "OT"
}

variable "app" {
  description = "Application name (e.g., network, shared). Max 10 characters."
  type        = string
  default     = "database"

  validation {
    condition     = length(var.app) <= 10
    error_message = "The app name must be less than or equal to 10 characters."
  }
}

variable "env" {
  description = "Environment code: 'd' (dev), 'p' (prod), 'q' (qa), 's' (stage), 'g' (global)."
  type        = string
  default     = "p"

  validation {
    condition     = contains(["d", "p", "q", "s", "g"], var.env)
    error_message = "env must be one of 'd', 'p', 'q', 's', 'g'."
  }
}

variable "team" {
  description = "Team email responsible for the application (e.g., digitalops@gehealthcare.com)."
  type        = string
  default     = "infra"
}

variable "region" {
  description = "AWS region (e.g., us-east-1, ap-south-1)."
  type        = string
  default     = "us-east-1"
}

variable "mission" {
  description = "Mission name or identifier for the project (max 20 characters)."
  type        = string
  default     = "infra-core"

  validation {
    condition     = length(var.mission) <= 20
    error_message = "The mission name must be less than or equal to 20 characters."
  }
}
