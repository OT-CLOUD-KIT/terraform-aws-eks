data "tls_certificate" "eks_cluster_oidc" {
  count = var.enable_oidc == true ? 1 : 0
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_cluster_oidc_provider" {
  count = var.enable_oidc == true ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}


########### IAM Policy for Cluster Autoscaler ########
data "aws_iam_policy_document" "cluster_autoscaler_assume_role_policy" {
  count = var.enable_oidc == true ? 1 : 0
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster_oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_cluster_oidc_provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "cluster_autoscaler" {
  count = var.enable_oidc == true ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role_policy.json
  name               = "cluster-autoscaler-role"
  tags = merge(
    var.tags,
    {
      "ServiceAccountName"      = "cluster-autoscaler"
      "ServiceAccountNameSpace" = "kube-system"
    }
  )
}

resource "aws_iam_policy" "autoscalling_tags" {
  count = var.enable_oidc == true ? 1 : 0
  name = "cluster-autoscaler-policy"
  path = "/"
  description = "resource tagging for autoscaler"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeTags",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*"
        }
    ]
}
EOF  
}

resource "aws_iam_role_policy_attachment" "autosclling_tags" {
  count = var.enable_oidc == true ? 1 : 0
  policy_arn = aws_iam_policy.autoscalling_tags.arn
  role       = aws_iam_role.cluster_autoscaler.name
}
