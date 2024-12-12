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