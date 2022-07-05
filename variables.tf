variable "cluster_name" {
  description = "EKS cluster name"
  default     = "terraform-eks-demo"
  type        = string
}

variable "cluster_autoscaler" {
  description = "For Cluster Cluster Autoscalling"
  default     = true
  type        = bool
}

variable "metrics_server" {
  description = "For Metrics Server"
  default     = true
  type        = bool
}

variable "k8s-spot-termination-handler" {
  description = "For Spot Instance termination handler"
  default     = true
  type        = bool
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

variable "subnets" {
  description = "A list of subnets for worker nodes"
  type        = list(string)
}

variable "eks_cluster_version" {
  description = "Kubernetes cluster version in EKS"
  type        = string
}

variable "scale_min_size" {
  description = "Minimum count of workers"
  type        = number
  default     = 2
}

variable "scale_max_size" {
  description = "Maximum count of workers"
  type        = number
  default     = 5
}

variable "scale_desired_size" {
  description = "Desired count of workers"
  type        = number
  default     = 3
}

variable "config_output_path" {
  description = "kubeconfig output path"
  type        = string
}

variable "kubeconfig_name" {
  description = "Name of kubeconfig file"
  type        = string
}

variable "endpoint_private" {
  description = "endpoint private"
  type        = bool
  default     = true
}
variable "endpoint_public" {
  description = "endpoint public"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "allow_eks_cidr" {
  description = "allow eks cidr"
  type        = list(string)
  default     = ["0.0.0.0/32"]
}

variable "cluster_endpoint_access_cidrs" {
  type        = list(string)
  description = "For list of cidr to whitelist"
  default     = []
}

variable "enabled_cluster_log_types" {
  description = "List of the desired control plane logging to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "secrets" {
  description = "Provide the list of secrets which needs to be encrypted"
  type        = list(string)
}

variable "create_encryption_config" {
  description = "Provide whether to create encryption config or not"
  type        = bool
  default     = true
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster"
  type = map(object({
    resources        = list(string)
  }))
}

variable "securitygroups" {
  description = "Provide the list of secondary SGs which needs to be attached with Cluster"
  type = list(string)
}

#################################
########## Node Group ###########
#################################

variable "node_groups" {
  description = "Paramters which are required for creating node group"
  default = {}
  type = map(object({
    subnets       = list(string)
    instance_type = list(string)
    desired_capacity = number
    max_capacity     = number
    min_capacity     = number
    tags            = map(string)
    labels          = map(string)
    capacity_type   = string
    launch_template = map(string)
    kubeargs        = string
    #sgingress       = any
    #sgegress       = any
  }))
}

variable "create_node_group" {
  description = "Create node group or not"
  type        = bool
  default = false
}

variable "force_update_version" {
  type        = bool
  description = "Force version update if existing pods are unable to be drained due to a pod disruption budget issue."
  default     = false
}

variable "eks_node_group_name" {
  description = "Node group name for EKS"
  default     = "eks-node-group"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "disk_size" {
  description = "Provide the disk size"
  type        = number
  default     = 0
}

variable "encrypted" {
  description = "Provide the encryption for EBS"
  type        = bool
  default     = true
}

variable "userdata_path" {
  description = "Provide the userdata file path"
  type        = string
  default = ""
}

variable "create_node_group_role" {
  description = "Provide value to create role"
  type = bool
  default = false 
}

variable "userdatafile" {
  type = bool
}

###############
### Fargate ###
###############

variable "fargate_profiles" {
  description = "Paramters which are required for creating fargate profile"
  default = {}
  type = map(object({
    subnets   = list(string)
    tags      = map(string)
    labels    = map(string)
    namespace = string
  }))
}

variable "account_id" {
  description = "Provide the account ID"
  type        = string
  default = ""
}

variable "create_fargate_role" {
  description = "Provide value to create role for fargate"
  type = bool
  default = false
}

#############
###  KMS  ###
#############

variable "deletion_window_in_days" {
  type        = number
  default     = 7
  description = "Duration in days after which the key is deleted after destruction of the resource"
}

variable "enable_key_rotation" {
  type        = bool
  default     = true
  description = "Specifies whether key rotation is enabled"
}

variable "description" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console"
}

variable "policy" {
  type        = string
  default     = ""
  description = "A valid KMS policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy."
}

variable "key_usage" {
  type        = string
  default     = "ENCRYPT_DECRYPT"
  description = "Specifies the intended use of the key. Valid values: `ENCRYPT_DECRYPT` or `SIGN_VERIFY`."
}

variable "customer_master_key_spec" {
  type        = string
  default     = "SYMMETRIC_DEFAULT"
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: `SYMMETRIC_DEFAULT`, `RSA_2048`, `RSA_3072`, `RSA_4096`, `ECC_NIST_P256`, `ECC_NIST_P384`, `ECC_NIST_P521`, or `ECC_SECG_P256K1`."
}

variable "multi_region" {
  type        = bool
  default     = false
  description = "Indicates whether the KMS key is a multi-Region (true) or regional (false) key."
}

variable "alias" {
  type = string
  description = "Provide the alias for the KMS"
}

###############
### SSH Key ###
###############
variable "create_key_pair" {
  description = "Controls if key pair should be created"
  type        = bool
  default     = true
}

variable "key_name" {
  description = "The name for the key pair."
  type        = string
  default     = null
}

variable "key_name_prefix" {
  description = "Creates a unique name beginning with the specified prefix. Conflicts with key_name."
  type        = string
  default     = null
}

variable "public_key" {
  description = "The public key material."
  type        = string
  default     = ""
}
