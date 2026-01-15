###################### Project Info ########################

variable "bu" {
  type        = string
  description = "Business unit code used in naming and tagging (example: BP, NEW)."
}

variable "program" {
  type        = string
  description = "Program name used in naming and tagging (example: OT)."
}

variable "app" {
  type        = string
  description = "Application name used in naming and tagging (example: database)."
}

variable "env" {
  type        = string
  description = "Environment code used in naming and tagging (example: d, p, q, s, g)."
}

variable "team" {
  type        = string
  description = "Owning team name/email for tagging and ownership tracking."
}

variable "region" {
  type        = string
  description = "AWS region where resources will be created (example: us-east-1)."
}

variable "mission" {
  type        = string
  description = "Mission identifier for tagging and project grouping."
}

###################### EKS Cluster #########################

variable "eks_cluster_version" {
  type        = string
  description = "EKS Kubernetes version to deploy (example: 1.29)."
}

variable "endpoint_private_access" {
  type        = bool
  description = "Enable private EKS API endpoint access within the VPC."
  default     = true
}

variable "endpoint_public_access" {
  type        = bool
  description = "Enable public EKS API endpoint access over the internet. Recommended to keep false for production."
  default     = false
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs used by the EKS control plane VPC configuration."
}

###################### IAM #################################

variable "eks_cluster_role_name" {
  type        = string
  description = "IAM role name used by the EKS control plane."
}

variable "eks_cluster_role_policy_arns" {
  type        = map(string)
  description = "Map of IAM policy ARNs attached to the EKS cluster role."
}

variable "eks_node_role_name" {
  type        = string
  description = "IAM role name used by EKS worker nodes (node groups)."
}

variable "eks_node_role_policy_arns" {
  type        = map(string)
  description = "Map of IAM policy ARNs attached to the EKS node group role."
}

###################### Security Groups #####################

variable "create_sg" {
  type        = bool
  description = "If true, security groups defined in security_groups_rule will be created by Terraform."
  default     = true
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS and security groups will be created."
}

variable "sg_names" {
  type        = list(string)
  description = "List of security group keys used for SG creation and naming (example: [\"app\", \"db\"])."
  default     = []
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

  description = <<EOT
Map of security group rules for EKS worker node security groups.
Each key in this map should match a value in sg_names.

Example structure:
security_groups_rule = {
  app = {
    name = "app"
    ingress_rules = [...]
    egress_rules  = [...]
  }
}
EOT

  default = {}
}

variable "eks_sg_rule" {
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
  }))

  description = "Ingress rules to allow traffic from worker node security groups into the EKS cluster security group (example: allow 443)."
  default     = []
}

###################### Node Groups #########################

variable "ami_type" {
  type        = string
  description = "EKS managed node group AMI type (example: AL2_x86_64, AL2_ARM_64)."
}

variable "key_pair" {
  type        = string
  description = "Optional EC2 key pair name to enable SSH access to worker nodes. Set empty string if not required."
  default     = ""
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

  description = <<EOT
Map of EKS managed node groups configuration.

Each node group defines:
- subnet_ids: Subnets where nodes will be launched
- instance_type: EC2 instance type (example: t3.micro)
- capacity_type: ON_DEMAND or SPOT
- scaling_config: desired/min/max node counts
- ebs: root volume configuration for nodes
- taint: Kubernetes taint for workload isolation
- sg_names: list of security group keys to attach (must exist in security group map if create_sg=true)
- labels: Kubernetes labels to assign to nodes

Example:
node_groups = {
  app = {
    subnet_ids          = ["subnet-xxx"]
    capacity_type       = "ON_DEMAND"
    instance_type       = "t3.micro"
    associate_public_ip = false

    scaling_config = {
      desired_size = 1
      min_size     = 1
      max_size     = 2
    }

    ebs = {
      volume_size           = 30
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }

    taint = {
      key    = "app"
      value  = "true"
      effect = "NO_SCHEDULE"
    }

    sg_names = ["app"]
    labels   = { role = "app" }
  }
}
EOT
}
