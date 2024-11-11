resource "aws_iam_role" "eks-role" {
  count              = length(var.roles)
  name               = var.roles[count.index].name
  assume_role_policy = file(var.roles[count.index].assume_policy)

  tags = {
    Name = var.roles[count.index].name
  }
}


# Attach Managed Policies to IAM Roles
resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  count = length(var.cluster-policy)
  role       = aws_iam_role.eks-role[0].name
  policy_arn = var.cluster-policy[count.index]
}
resource "aws_iam_role_policy_attachment" "eks-node-policy" {
    count      = length(var.node-policy)
    role       = aws_iam_role.eks-role[1].name
    policy_arn = var.node-policy[count.index] 
}


# Attach Inline Policies to IAM Roles (if any)
# resource "aws_iam_role_policy" "inline_policies" {
#   for_each = {
#     for role in var.roles :
#     role.name => role.inline_policies != null ? role.inline_policies : []
#   }

#   role   = aws_iam_role.this[each.key].name
#   name   = each.value.name
#   policy = file(each.value.policy)
# }


# "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
#       "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
#       "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
