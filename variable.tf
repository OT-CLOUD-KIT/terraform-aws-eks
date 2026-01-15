###################### EKS Cluster #########################

variable "eks_cluster_version" {
  type        = string
  description = "EKS Kubernetes version to deploy (example: 1.29)."
}

variable "endpoint_private_access" {
  type        = bool
  description = "Enable private access to the EKS API server endpoint within the VPC."
  default     = true
}

variable "endpoint_public_access" {
  type        = bool
  description = "Enable public access to the EKS API server endpoint over the internet."
  default     = false
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs to attach to the EKS cluster VPC configuration."
  default     = []
}

###################### IAM Configuration ###################

variable "eks_cluster_role_name" {
  type        = string
  description = "IAM role name used by the EKS control plane (cluster role)."
}

variable "eks_cluster_role_policy_arns" {
  type        = map(string)
  description = "Map of IAM managed policy ARNs to attach to the EKS cluster IAM role."
}

variable "eks_node_role_name" {
  type        = string
  description = "IAM role name used by EKS managed node groups (worker node role)."
}

variable "eks_node_role_policy_arns" {
  type        = map(string)
  description = "Map of IAM managed policy ARNs to attach to the worker node IAM role."
}

###################### Security Groups #####################

variable "create_sg" {
  type        = bool
  description = "If true, create security groups using security_groups_rule; if false, skip SG creation."
  default     = true
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS and related security groups will be created."
}

variable "sg_names" {
  type        = list(string)
  description = "List of security group keys/names to generate SG resources (example: [\"app\", \"db\"])."
  default     = []
}

variable "security_groups_rule" {
  description = "Map of security group rules including ingress and egress definitions for each SG."
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

variable "eks_sg_rule" {
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
  }))
  description = "Ingress rules to allow worker node security groups to reach the EKS cluster security group (example: allow 443)."
}

###################### Node Group Common ###################

variable "ami_type" {
  type        = string
  description = "EKS node group AMI type (example: AL2_x86_64, AL2_ARM_64)."
}

variable "key_pair" {
  type        = string
  default     = ""
  description = "Optional EC2 key pair name to enable SSH access to worker nodes. Set empty string if not required."
}

###################### Node Groups #########################

variable "node_groups" {
  description = "Map of EKS managed node group configurations (example: app, db, monitoring)."
  type = map(object({
    subnet_ids = list(string)
    capacity_type = string
    instance_type = string

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

###################### Tagging / Naming Inputs #############

variable "bu" {
  type        = string
  description = "Business unit identifier used for resource naming and common tags."
}

variable "program" {
  type        = string
  description = "Program name used for naming conventions and common tags."
}

variable "app" {
  type        = string
  description = "Application name used for naming conventions and common tags."
}

variable "env" {
  type        = string
  description = "Environment identifier used for naming and tagging (example: d, p, q, s, g)."
}

variable "team" {
  type        = string
  description = "Owning team name/email used for tagging and ownership tracking."
}

variable "region" {
  type        = string
  description = "AWS region used for tagging and deployment context."
}

variable "mission" {
  type        = string
  description = "Mission identifier used for tagging and grouping related infrastructure."
}
