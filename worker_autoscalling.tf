provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.authentication.token
  }
}

data "aws_eks_cluster_auth" "authentication" {
  name = var.cluster_name
}

resource "helm_release" "cluster_autoscaler" {
  count      = var.cluster_autoscaler ? 1 : 0
  name       = "clusterautoscaler"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "7.3.4"
  depends_on = [aws_eks_cluster.eks_cluster]

  set {
    name  = "awsRegion"
    value = var.region
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
}

resource "helm_release" "metrics_server" {
  count      = var.metrics_server ? 1 : 0
  name       = "metricsserver"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version = "2.11.1"
  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "helm_release" "k8s-spot-termination-handler" {
  count      = var.k8s-spot-termination-handler ? 1 : 0
  name       = "verticalautoscaling"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "k8s-spot-termination-handler"
  namespace  = "kube-system"
  depends_on = [aws_eks_cluster.eks_cluster]

  set {
    name  = "slackUrl"
    value = var.slackUrl
  }
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
}
