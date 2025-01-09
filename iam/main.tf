resource "aws_iam_role" "eks-role" {
  count              = length(var.roles)
  name               = var.roles[count.index].name
  assume_role_policy = file(var.roles[count.index].assume_policy)

  tags = {
    Name = var.roles[count.index].name
  }
}


# Attach Managed Policies to IAM Roles
resource "aws_iam_role_policy_attachment" "eks-cluster_policy" {
  count      = length(var.cluster_policy)
  role       = aws_iam_role.eks-role[0].name
  policy_arn = var.cluster_policy[count.index]
}
resource "aws_iam_role_policy_attachment" "eks-node_policy" {
  count      = length(var.node_policy)
  role       = aws_iam_role.eks-role[1].name
  policy_arn = var.node_policy[count.index]
}



####Cluster-Autoscaler-policies####

# Create and attach Cluster Autoscaler Policy
resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name        = "AmazonEKSClusterAutoscalerPolicy"
  description = "IAM policy for EKS Cluster Autoscaler"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstances",
          "ec2:DescribeSubnets",
          "eks:DescribeNodegroup"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach Cluster Autoscaler Policy to Node Group Role
resource "aws_iam_role_policy_attachment" "autoscaler_policy_attachment" {
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
  role       = aws_iam_role.eks-role[1].name # Assuming the Node Group Role is at index 1
}