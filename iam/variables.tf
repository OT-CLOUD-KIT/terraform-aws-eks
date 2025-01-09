variable "roles" {
  description = "List of IAM roles to create."
  type = list(object({
    name          = string
    assume_policy = string
  }))
}
variable "cluster_policy" {
  type = list(string)
}
variable "node_policy" {
  type = list(string)
}