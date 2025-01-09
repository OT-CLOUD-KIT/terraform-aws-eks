output "eks-roles" {
  value = aws_iam_role.eks-role[*].arn
}