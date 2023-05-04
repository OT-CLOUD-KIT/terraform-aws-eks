terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    exec {
      api_version = var.api_version
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 5
    host                   = aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  load_config_file       = false

    exec {
      api_version = var.api_version
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
}


resource "kubectl_manifest" "karpenter_provisioner" {
  yaml_body = file("${path.module}/${var.provisioner_path}")

}

resource "kubectl_manifest" "karpenter_node_template" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: default
    spec:
      subnetSelector:
        karpenter.sh/discovery:  ${var.cluster_name}
      securityGroupSelector:
        karpenter.sh/discovery:  ${var.cluster_name}
      tags:
        karpenter.sh/discovery: ${var.cluster_name}
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "v0.13.1"


  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.irsa_arn
  }

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks_cluster.id
  }

  set {
    name  = "clusterEndpoint"
    value = aws_eks_cluster.eks_cluster.endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = module.karpenter.instance_profile_name
  }

}

resource "aws_ec2_tag" "subnets" {
  for_each    = toset(var.subnets)
  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
} 

resource "aws_ec2_tag" "security_group" {
  resource_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       =  var.cluster_name
} 



